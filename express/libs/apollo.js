const { ApolloClient, InMemoryCache } = require("apollo-boost");
const createHttpLink = require("apollo-link-http").createHttpLink;
const fetch = require("cross-fetch/polyfill").fetch;

module.exports = new ApolloClient({
  link: createHttpLink({
    uri: process.env.HASURA_GRAPHQL_URL,
    fetch: fetch,
    headers: {
      "x-hasura-admin-secret": process.env.HASURA_GRAPHQL_ADMIN_SECRET,
    },
  }),
  cache: new InMemoryCache({
    addTypename: false,
  }),
});
