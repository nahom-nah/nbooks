const apollo = require("../libs/apollo");
const normalizeCredentials = require("../helpers/normalize-credentials");
const correctPhone = require("../helpers/correct-phone");
const hashPassword = require("../helpers/hash-password");
const getNestedSafe = require("../helpers/get-nested-safe");
const getAgentChain = require("../helpers/get-agent-chain");
const bcrypt = require("bcryptjs");
const { gql } = require("apollo-boost");
const jwt = require("jsonwebtoken");

const usernameExp = /^(?=.{4,20}$)[a-zA-Z0-9._@]+$/;
const phoneExp = /^(^\+251|^251|^0)?9\d{8}$/;
const emailExp =
  /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;

const GET_USER = gql`
  query get_user($where: user_bool_exp!) {
    user(limit: 1, where: $where) {
      id
      username
      full_name
      email
      phone
      is_active
      password
      outletid
      distributorid
      password_changed
      role {
        slug
        name
      }
      region: teleregion {
        name
        description
        capital
      }
      distributor {
        name
        active
        allow_agent_chain
        stockid
      }
      outlet {
        name
        active
      }
      parent {
        id
        full_name
        username
        phone
        is_active
      }
    }
  }
`;

const login = async (req, res) => {
  try {
    const { password } = req.body.input.objects;

    let query = normalizeCredentials(req.body.input.objects);

    const user_info = await apollo.query({
      query: GET_USER,
      variables: { where: query },
      fetchPolicy: "no-cache",
    });

    const user = getNestedSafe(() => user_info.data.user[0], null);

    if (!user) {
      throw new Error("User not found!");
    } else if (user.distributor && !user.distributor.active) {
      throw new Error("Inactive Distributor!");
    } else if (user.outlet && !user.outlet.active) {
      throw new Error("Inactive Outlet!");
    } else if (user.parent && !user.parent.is_active) {
      throw new Error("Inactive Parent!");
    } else if (!user.is_active) {
      throw new Error("Inactive Account!");
    } else if (!(await bcrypt.compare(password, user.password))) {
      throw new Error("Invalid Credentials!");
    }

    const hasura_token = {
      sub: user.id,
      username: user.username,
      iat: Date.now() / 1000,
      airevd: {
        "x-hasura-allowed-roles": ["User", "anonymous", user.role.slug],
        "x-hasura-user-id": "" + user.id,
        "x-hasura-username": "" + user.username,
        "x-hasura-distributor-id": "" + user.distributorid,
        "x-hasura-outlet-id": "" + user.outletid,
        "x-hasura-stock-id": "" + getNestedSafe(() => user.distributor.stockid),
        "x-hasura-default-role": user.role.slug,
      },
      exp: Math.floor(Date.now() / 1000) + 28800,
    };

    const user_metadata = {
      id: user.id,
      full_name: user.full_name,
      username: user.username,
      phone: user.phone,
      email: user.email,
      role: user.role,
      distributor: user.distributor,
      outlet: user.outlet,
      parent: user.parent,
      password_changed: user.password_changed,
      teleregion: user.region,
      exp: Math.floor(Date.now()) + 28800000,
    };

    const accessToken = jwt.sign(hasura_token, process.env.ENCRYPTION_KEY, {
      algorithm: "HS256",
    });

    // update user last_login
    await apollo.mutate({
      mutation: gql`
        mutation update_last_login($last_login: timestamptz!, $id: uuid!) {
          update_user_by_pk(
            pk_columns: { id: $id }
            _set: { last_login: $last_login }
          ) {
            id
          }
        }
      `,
      variables: {
        last_login: new Date(),
        id: user.id,
      },
    });

    res.status(200).json({
      token: accessToken,
      metadata: JSON.stringify(user_metadata),
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "LOGIN_ERROR",
    });
  }
};

const create_user = async (req, res) => {
  try {
    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      username: req.body.session_variables["x-hasura-username"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      outletid: req.body.session_variables["x-hasura-outlet-id"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    const {
      username,
      password,
      full_name,
      email,
      phone,
      roleid,
      distributorid,
      outletid,
      sellon,
      city: cityData,
      zone: zoneData,
      region: regionData,
      teleregionid,
      area,
      sex,
    } = req.body.input.objects;

    // get user from apollo
    const single_user_info = await apollo.query({
      query: gql`
        query get_user($id: uuid!) {
          user_by_pk(id: $id) {
            id
            stockid
          }
        }
      `,
      variables: {
        id: user_info.userid,
      },
      fetchPolicy: "no-cache",
    });

    const parent_user = getNestedSafe(
      () => single_user_info.data.user_by_pk,
      null
    );

    let userEmail = "";
    let newUserDistId = distributorid;
    let newUserOutletId = outletid;
    let userSellon = sellon;
    let distributor_info = null;

    if (user_info.distributorid !== "null") {
      distributor_info = await apollo.query({
        query: gql`
          query get_distributor($where: distributor_bool_exp!) {
            distributor(where: $where) {
              id
              allow_agent_chain
              stockid
            }
          }
        `,
        variables: { where: { id: { _eq: user_info.distributorid } } },
        fetchPolicy: "no-cache",
      });
    }

    const distributor = getNestedSafe(
      () => distributor_info.data.distributor[0],
      {}
    );

    if (!email) userEmail = `${username}@${username}.com`;
    else userEmail = email;

    let roles_info = await apollo.query({
      query: gql`
        query get_roles {
          role {
            id
            name
            slug
          }
        }
      `,
      fetchPolicy: "no-cache",
    });

    let roles = getNestedSafe(() => roles_info.data.role, []);

    let creator = {},
      created = {};

    roles.forEach((role) => {
      if (role.slug === user_info.user_role) {
        creator = role;
      }
      if (role.id === roleid) {
        created = role;
      }
    });

    if (creator.slug === "Retailer") {
      let distributor_info = await apollo.query({
        query: gql`
          query get_distributor($where: distributor_bool_exp!) {
            distributor(where: $where) {
              id
              allow_agent_chain
            }
          }
        `,
        variables: { where: { id: { _eq: user_info.distributorid } } },
        fetchPolicy: "no-cache",
      });

      let distributor = getNestedSafe(
        () => distributor_info.data.distributor[0],
        null
      );

      if (!distributor || !distributor.allow_agent_chain) {
        throw new Error("Method not allowed!");
      }
    }

    if (
      creator !== {} &&
      created !== {} &&
      creator.slug === "Admin" &&
      (created.slug === "Admin" ||
        created.slug === "Regulator" ||
        created.slug === "Manager" ||
        created.slug === "Finance" ||
        created.slug === "Marketing" ||
        created.slug === "CCD" ||
        created.slug === "Importer" ||
        created.slug === "DE" ||
        created.slug === "HR" ||
        created.slug === "ViewOnly" ||
        created.slug === "Auditor")
    ) {
      await userCreator();
    } else if (
      creator !== {} &&
      created !== {} &&
      creator.slug === "Coordinator" &&
      (created.slug === "Sales" || created.slug === "Agent")
    ) {
      newUserDistId = user_info.distributorid;
      newUserOutletId = user_info.outletid;
      await userCreator();
    } else if (
      creator !== {} &&
      created !== {} &&
      creator.slug === "Sales" &&
      created.slug === "Retailer"
    ) {
      newUserDistId = user_info.distributorid;
      newUserOutletId = user_info.outletid;
      await userCreator();
    } else if (
      creator !== {} &&
      created !== {} &&
      creator.slug === "Agent" &&
      created.slug === "Retailer"
    ) {
      newUserDistId = user_info.distributorid;
      newUserOutletId = user_info.outletid;
      await userCreator();
    } else if (
      creator !== {} &&
      created !== {} &&
      creator.slug === "Retailer" &&
      created.slug === "Retailer"
    ) {
      newUserDistId = user_info.distributorid;
      newUserOutletId = user_info.outletid;
      await userCreator();
    } else {
      throw new Error("Method not allowed!");
    }

    async function userCreator() {
      let selected_region, selected_zone, selected_city;

      if (cityData && zoneData && regionData) {
        let selected_region_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_region($objects: [region_insert_input!]!) {
              insert_region(
                on_conflict: {
                  constraint: telecomregion_name_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: regionData,
              },
            ],
          },
        });

        selected_region = getNestedSafe(
          () => selected_region_info.data.insert_region.returning[0],
          null
        );

        let selected_zone_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_zone($objects: [zone_insert_input!]!) {
              insert_zone(
                on_conflict: {
                  constraint: zone_name_regionid_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: zoneData,
                regionid: selected_region.id,
              },
            ],
          },
        });

        selected_zone = getNestedSafe(
          () => selected_zone_info.data.insert_zone.returning[0],
          null
        );

        let selected_city_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_city($objects: [city_insert_input!]!) {
              insert_city(
                on_conflict: {
                  constraint: city_name_zoneid_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: cityData,
                zoneid: selected_zone.id,
              },
            ],
          },
        });

        selected_city = getNestedSafe(
          () => selected_city_info.data.insert_city.returning[0],
          null
        );
      }

      if (!usernameExp.exec(username.trim().toLowerCase())) {
        throw new Error("Incorrect Username!");
      }

      if (!emailExp.exec(userEmail.trim())) {
        throw new Error("Incorrect Email!");
      }

      if (!phoneExp.exec(phone.trim())) {
        throw new Error("Incorrect Phone!");
      }

      let create_user_info = await apollo.mutate({
        mutation: gql`
          mutation insert_user(
            $objects: [user_insert_input!]!
            $log_objects: [user_log_insert_input!]!
          ) {
            insert_user(objects: $objects) {
              affected_rows
            }
            insert_user_log(objects: $log_objects) {
              affected_rows
            }
          }
        `,
        variables: {
          objects: [
            {
              full_name: full_name.trim(),
              username: username.trim().toLowerCase(),
              email: userEmail.trim().toLowerCase(),
              phone: correctPhone(phone),
              password: hashPassword(password),
              roleid,
              distributorid: newUserDistId,
              outletid: newUserOutletId,
              parentid:
                created.slug === "Retailer" ? user_info.userid : undefined,
              stockid: parent_user.stockid || distributor.stockid,
              sellon: userSellon || 0,
              regionid: selected_region ? selected_region.id : undefined,
              zoneid: selected_zone ? selected_zone.id : undefined,
              cityid: selected_city ? selected_city.id : undefined,
              teleregionid,
              area,
              sex,
              password_changed: true,
              balances: {
                data: {
                  balance: 0,
                },
              },
            },
          ],
          log_objects: [
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] create user [${username
                .trim()
                .toLowerCase()}].`,
              slug: "create_user",
            },
          ],
        },
      });
    }

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "CREATE_USER_ERROR",
    });
  }
};

const create_dist_and_user = async (req, res) => {
  try {
    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      username: req.body.session_variables["x-hasura-username"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    const {
      username,
      password,
      full_name,
      name,
      phone,
      roleid,
      sellon,
      area,
      city: cityData,
      zone: zoneData,
      region: regionData,
      teleregionid,
      sex,
    } = req.body.input.objects;

    let userEmail = `${username}@${username}.com`;

    let roles_info = await apollo.query({
      query: gql`
        query get_roles {
          role {
            id
            name
            slug
          }
        }
      `,
      fetchPolicy: "no-cache",
    });

    let roles = getNestedSafe(() => roles_info.data.role, []);

    let creator = {},
      created = {};

    roles.forEach((role) => {
      if (role.slug === user_info.user_role) {
        creator = role;
      }
      if (role.id === roleid) {
        created = role;
      }
    });

    if (
      creator !== {} &&
      created !== {} &&
      (creator.slug === "Admin" || creator.slug === "CCD") &&
      created.slug === "Manager"
    ) {
      await userCreator();
    } else {
      throw new Error("Method not allowed!");
    }

    async function userCreator() {
      let selected_region, selected_zone, selected_city;

      if (cityData && zoneData && regionData) {
        let selected_region_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_region($objects: [region_insert_input!]!) {
              insert_region(
                on_conflict: {
                  constraint: telecomregion_name_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: regionData,
              },
            ],
          },
        });

        selected_region = getNestedSafe(
          () => selected_region_info.data.insert_region.returning[0],
          null
        );

        let selected_zone_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_zone($objects: [zone_insert_input!]!) {
              insert_zone(
                on_conflict: {
                  constraint: zone_name_regionid_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: zoneData,
                regionid: selected_region.id,
              },
            ],
          },
        });

        selected_zone = getNestedSafe(
          () => selected_zone_info.data.insert_zone.returning[0],
          null
        );

        let selected_city_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_city($objects: [city_insert_input!]!) {
              insert_city(
                on_conflict: {
                  constraint: city_name_zoneid_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: cityData,
                zoneid: selected_zone.id,
              },
            ],
          },
        });

        selected_city = getNestedSafe(
          () => selected_city_info.data.insert_city.returning[0],
          null
        );
      }

      if (!usernameExp.exec(username.trim().toLowerCase())) {
        throw new Error("Incorrect Username!");
      }

      if (!emailExp.exec(userEmail.trim())) {
        throw new Error("Incorrect Email!");
      }

      if (!phoneExp.exec(phone.trim())) {
        throw new Error("Incorrect Phone!");
      }

      let create_user_info = await apollo.mutate({
        mutation: gql`
          mutation insert_user(
            $objects: [user_insert_input!]!
            $log_objects: [user_log_insert_input!]!
          ) {
            insert_user(objects: $objects) {
              affected_rows
            }
            insert_user_log(objects: $log_objects) {
              affected_rows
            }
          }
        `,
        variables: {
          objects: [
            {
              full_name: full_name.trim(),
              username: username.trim().toLowerCase(),
              email: userEmail.trim().toLowerCase(),
              phone: correctPhone(phone),
              password: hashPassword(password),
              roleid,
              distributor: {
                data: {
                  name: name.trim(),
                  sellon: sellon || 0,
                  phone: correctPhone(phone),
                },
              },
              sellon: sellon || 0,
              regionid: selected_region ? selected_region.id : undefined,
              zoneid: selected_zone ? selected_zone.id : undefined,
              cityid: selected_city ? selected_city.id : undefined,
              password_changed: true,
              teleregionid,
              area,
              sex,
            },
          ],
          log_objects: [
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] create user [${username
                .trim()
                .toLowerCase()}].`,
              slug: "create_user",
            },
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] create distributor [${name}].`,
              slug: "create_distributor",
            },
          ],
        },
      });
    }

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "CREATE_DIST_AND_USER_ERROR",
    });
  }
};

const create_outlet_and_user = async (req, res) => {
  try {
    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      username: req.body.session_variables["x-hasura-username"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      outletid: req.body.session_variables["x-hasura-outlet-id"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    const {
      username,
      password,
      full_name,
      name,
      phone,
      roleid,
      sellon,
      area,
      city: cityData,
      zone: zoneData,
      region: regionData,
      teleregionid,
      sex,
    } = req.body.input.objects;

    let userEmail = `${username}@${username}.com`;

    let roles_info = await apollo.query({
      query: gql`
        query get_roles {
          role {
            id
            name
            slug
          }
        }
      `,
      fetchPolicy: "no-cache",
    });

    let roles = getNestedSafe(() => roles_info.data.role, []);

    let creator = {},
      created = {};

    roles.forEach((role) => {
      if (role.slug === user_info.user_role) {
        creator = role;
      }
      if (role.id === roleid) {
        created = role;
      }
    });

    if (
      creator !== {} &&
      created !== {} &&
      creator.slug === "Manager" &&
      created.slug === "Coordinator"
    ) {
      await userCreator();
    } else {
      throw new Error("Method not allowed!");
    }

    async function userCreator() {
      let selected_region, selected_zone, selected_city;

      if (cityData && zoneData && regionData) {
        let selected_region_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_region($objects: [region_insert_input!]!) {
              insert_region(
                on_conflict: {
                  constraint: telecomregion_name_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: regionData,
              },
            ],
          },
        });

        selected_region = getNestedSafe(
          () => selected_region_info.data.insert_region.returning[0],
          null
        );

        let selected_zone_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_zone($objects: [zone_insert_input!]!) {
              insert_zone(
                on_conflict: {
                  constraint: zone_name_regionid_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: zoneData,
                regionid: selected_region.id,
              },
            ],
          },
        });

        selected_zone = getNestedSafe(
          () => selected_zone_info.data.insert_zone.returning[0],
          null
        );

        let selected_city_info = await apollo.mutate({
          mutation: gql`
            mutation insert_or_get_city($objects: [city_insert_input!]!) {
              insert_city(
                on_conflict: {
                  constraint: city_name_zoneid_key
                  update_columns: updated_at
                }
                objects: $objects
              ) {
                returning {
                  id
                  name
                }
              }
            }
          `,
          variables: {
            objects: [
              {
                name: cityData,
                zoneid: selected_zone.id,
              },
            ],
          },
        });

        selected_city = getNestedSafe(
          () => selected_city_info.data.insert_city.returning[0],
          null
        );
      }

      if (!usernameExp.exec(username.trim().toLowerCase())) {
        throw new Error("Incorrect Username!");
      }

      if (!emailExp.exec(userEmail.trim())) {
        throw new Error("Incorrect Email!");
      }

      if (!phoneExp.exec(phone.trim())) {
        throw new Error("Incorrect Phone!");
      }

      let create_user_info = await apollo.mutate({
        mutation: gql`
          mutation insert_user(
            $objects: [user_insert_input!]!
            $log_objects: [user_log_insert_input!]!
          ) {
            insert_user(objects: $objects) {
              affected_rows
            }
            insert_user_log(objects: $log_objects) {
              affected_rows
            }
          }
        `,
        variables: {
          objects: [
            {
              full_name: full_name.trim(),
              username: username.trim().toLowerCase(),
              email: userEmail.trim().toLowerCase(),
              phone: correctPhone(phone),
              password: hashPassword(password),
              roleid,
              outlet: {
                data: {
                  name: name.trim(),
                  sellon: sellon || 0,
                  phone: correctPhone(phone),
                  distributorid: user_info.distributorid,
                },
              },
              sellon: sellon || 0,
              regionid: selected_region ? selected_region.id : undefined,
              zoneid: selected_zone ? selected_zone.id : undefined,
              cityid: selected_city ? selected_city.id : undefined,
              password_changed: true,
              distributorid: user_info.distributorid,
              teleregionid,
              area,
              sex,
            },
          ],
          log_objects: [
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] create user [${username
                .trim()
                .toLowerCase()}].`,
              slug: "create_user",
            },
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] create outlet [${name}].`,
              slug: "create_outlet",
            },
          ],
        },
      });
    }

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "CREATE_OUTLET_AND_USER_ERROR",
    });
  }
};

const activate_deactivate = async (req, res) => {
  try {
    const { userid, activate } = req.body.input.objects;

    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      username: req.body.session_variables["x-hasura-username"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    // get user from apollo
    const single_user_info = await apollo.query({
      query: gql`
        query get_user($id: uuid!) {
          user_by_pk(id: $id) {
            id
            username
            distributorid
            parentid
            role {
              id
              slug
            }
          }
        }
      `,
      variables: {
        id: userid,
      },
      fetchPolicy: "no-cache",
    });

    const user = getNestedSafe(() => single_user_info.data.user_by_pk, null);

    const agent_list = await getAgentChain(userid);

    if (!user) {
      throw new Error("User not found!");
    } else if (
      user.id != user_info.userid &&
      (user_info.user_role == "Admin" ||
        user_info.user_role == "CCD" ||
        user.parentid == user_info.userid ||
        (user_info.user_role == "Manager" &&
          user.distributorid == user_info.distributorid))
    ) {
      let activate_deactivate_info = await apollo.mutate({
        mutation: gql`
          mutation insert_user(
            $user_list: [uuid!]!
            $is_active: Boolean!
            $log_objects: [user_log_insert_input!]!
          ) {
            update_user(
              _set: { is_active: $is_active }
              where: { id: { _in: $user_list } }
            ) {
              affected_rows
            }
            insert_user_log(objects: $log_objects) {
              affected_rows
            }
          }
        `,
        variables: {
          user_list: agent_list,
          is_active: activate,
          log_objects: [
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] ${
                activate ? "activate" : "deactivate"
              } [${user.username}]${
                agent_list.length > 1
                  ? ` and its [${agent_list.length - 1}] sub agents.`
                  : "."
              }`,
              slug: `${activate ? "Activate" : "Deactivate"}`,
            },
          ],
        },
      });

      res.status(200).json({
        status: true,
      });
    }
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "ACTIVATE_DEACTIVATE_ERROR",
    });
  }
};

const update_password = async (req, res) => {
  try {
    const { new_password, old_password } = req.body.input.objects;

    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      username: req.body.session_variables["x-hasura-username"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    // get user from apollo
    const single_user_info = await apollo.query({
      query: gql`
        query get_user($id: uuid!) {
          user_by_pk(id: $id) {
            id
            username
            password
          }
        }
      `,
      variables: {
        id: user_info.userid,
      },
      fetchPolicy: "no-cache",
    });

    const user = getNestedSafe(() => single_user_info.data.user_by_pk, null);

    if (!(await bcrypt.compare(old_password, user.password))) {
      throw new Error("Invalid current password.");
    }

    if (!user) {
      throw new Error("User not found!");
    }

    let update_password_info = await apollo.mutate({
      mutation: gql`
        mutation insert_user(
          $id: uuid!
          $password: String!
          $log_objects: [user_log_insert_input!]!
        ) {
          update_user_by_pk(
            _set: { password: $password, password_changed: false }
            pk_columns: { id: $id }
          ) {
            id
          }
          insert_user_log(objects: $log_objects) {
            affected_rows
          }
        }
      `,
      variables: {
        id: user_info.userid,
        password: hashPassword(new_password),
        log_objects: [
          {
            userid: user_info.userid,
            info: `User [${user_info.username}] updated his/her account password.`,
            slug: `update_password`,
          },
        ],
      },
    });

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "UPDATE_PASSWORD_ERROR",
    });
  }
};

const reset_password = async (req, res) => {
  try {
    const { new_password, userid } = req.body.input.objects;

    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      username: req.body.session_variables["x-hasura-username"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    // get user from apollo
    const single_user_info = await apollo.query({
      query: gql`
        query get_user($id: uuid!) {
          user_by_pk(id: $id) {
            id
            username
            password
          }
        }
      `,
      variables: {
        id: userid,
      },
      fetchPolicy: "no-cache",
    });

    const user = getNestedSafe(() => single_user_info.data.user_by_pk, null);

    if (!user) {
      throw new Error("User not found!");
    } else if (
      user &&
      user.id != user_info.userid &&
      user_info.user_role == "Admin"
    ) {
      let reset_password_info = await apollo.mutate({
        mutation: gql`
          mutation insert_user(
            $id: uuid!
            $password: String!
            $log_objects: [user_log_insert_input!]!
          ) {
            update_user_by_pk(
              _set: { password: $password, password_changed: false }
              pk_columns: { id: $id }
            ) {
              id
            }
            insert_user_log(objects: $log_objects) {
              affected_rows
            }
          }
        `,
        variables: {
          id: userid,
          password: hashPassword(new_password),
          log_objects: [
            {
              userid: user_info.userid,
              info: `User [${user_info.username}] reset [${user.username}] account password.`,
              slug: `password_reseted`,
            },
          ],
        },
      });

      res.status(200).json({
        status: true,
      });
    } else {
      throw new Error("Reset password not allowed.");
    }
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "RESET_PASSWORD_ERROR",
    });
  }
};

const update_profile = async (req, res) => {
  try {
    const { id, full_name, email, phone } = req.body.input.objects;

    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      username: req.body.session_variables["x-hasura-username"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    if (id != user_info.userid) {
      throw new Error("Method not allowed!");
    }

    if (!emailExp.exec(email.trim())) {
      throw new Error("Incorrect Email!");
    }

    if (!phoneExp.exec(phone.trim())) {
      throw new Error("Incorrect Phone!");
    }

    // get user from apollo
    const single_user_info = await apollo.query({
      query: gql`
        query get_user($id: uuid!) {
          user_by_pk(id: $id) {
            id
            username
            password
          }
        }
      `,
      variables: {
        id,
      },
      fetchPolicy: "no-cache",
    });

    const user = getNestedSafe(() => single_user_info.data.user_by_pk, null);

    if (!user) {
      throw new Error("User not found!");
    }

    let update_profile_info = await apollo.mutate({
      mutation: gql`
        mutation insert_user(
          $id: uuid!
          $_set: user_set_input!
          $log_objects: [user_log_insert_input!]!
        ) {
          update_user_by_pk(_set: $_set, pk_columns: { id: $id }) {
            id
          }
          insert_user_log(objects: $log_objects) {
            affected_rows
          }
        }
      `,
      variables: {
        id,
        _set: {
          full_name: full_name.trim(),
          email: email.trim().toLowerCase(),
          phone: correctPhone(phone),
        },
        log_objects: [
          {
            userid: user_info.userid,
            info: `User [${user_info.username}] updates profile.`,
            slug: `update_profile`,
          },
        ],
      },
    });

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "RESET_PASSWORD_ERROR",
    });
  }
};

const update_credit_limit = async (req, res) => {
  try {
    const { id, credit_limit } = req.body.input.objects;

    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      username: req.body.session_variables["x-hasura-username"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    if (user_info.user_role !== "Admin" && user_info.user_role !== "HR") {
      throw new Error("Method not allowed!");
    }

    // get user from apollo
    const single_user_info = await apollo.query({
      query: gql`
        query get_user($id: uuid!) {
          user_by_pk(id: $id) {
            id
            username
            password
            credit_limit
          }
        }
      `,
      variables: {
        id,
      },
      fetchPolicy: "no-cache",
    });

    const user = getNestedSafe(() => single_user_info.data.user_by_pk, null);

    if (!user) {
      throw new Error("User not found!");
    }

    let update_profile_info = await apollo.mutate({
      mutation: gql`
        mutation insert_user(
          $id: uuid!
          $_set: user_set_input!
          $log_objects: [user_log_insert_input!]!
        ) {
          update_user_by_pk(_set: $_set, pk_columns: { id: $id }) {
            id
          }
          insert_user_log(objects: $log_objects) {
            affected_rows
          }
        }
      `,
      variables: {
        id,
        _set: {
          credit_limit,
        },
        log_objects: [
          {
            userid: user_info.userid,
            info: `User [${user_info.username}] updates credit limit of user [${user.username}] from [${user.credit_limit}] to [${credit_limit}].`,
            slug: `update_credit_limit`,
          },
        ],
      },
    });

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "CREDIT_LIMIT_ERROR",
    });
  }
};

const update_outlet_credit_limit = async (req, res) => {
  try {
    const { id, credit_limit } = req.body.input.objects;

    const user_info = {
      userid: req.body.session_variables["x-hasura-user-id"],
      distributorid: req.body.session_variables["x-hasura-distributor-id"],
      username: req.body.session_variables["x-hasura-username"],
      user_role: req.body.session_variables["x-hasura-role"],
    };

    if (user_info.user_role !== "Admin" && user_info.user_role !== "HR") {
      throw new Error("Method not allowed!");
    }

    // get outlet from apollo
    const single_outlet_info = await apollo.query({
      query: gql`
        query get_outlet($id: uuid!) {
          outlet_by_pk(id: $id) {
            id
            name
            phone
            credit_limit
          }
        }
      `,
      variables: {
        id,
      },
      fetchPolicy: "no-cache",
    });

    const outlet = getNestedSafe(
      () => single_outlet_info.data.outlet_by_pk,
      null
    );

    if (!outlet) {
      throw new Error("User not found!");
    }

    let update_outlet_info = await apollo.mutate({
      mutation: gql`
        mutation insert_outlet(
          $id: uuid!
          $_set: outlet_set_input!
          $log_objects: [user_log_insert_input!]!
        ) {
          update_outlet_by_pk(_set: $_set, pk_columns: { id: $id }) {
            id
          }
          insert_user_log(objects: $log_objects) {
            affected_rows
          }
        }
      `,
      variables: {
        id,
        _set: {
          credit_limit,
        },
        log_objects: [
          {
            userid: user_info.userid,
            info: `User [${user_info.username}] updates credit limit of outlet [${outlet.name}] from [${outlet.credit_limit}] to [${credit_limit}].`,
            slug: `update_outlet_credit_limit`,
          },
        ],
      },
    });

    res.status(200).json({
      status: true,
    });
  } catch (error) {
    res.status(422).json({
      message: error.message,
      code: "OUTLET_CREDIT_LIMIT_ERROR",
    });
  }
};

module.exports = {
  login,
  create_user,
  create_dist_and_user,
  create_outlet_and_user,
  activate_deactivate,
  update_password,
  reset_password,
  update_profile,
  update_credit_limit,
  update_outlet_credit_limit,
};
