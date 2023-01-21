CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."region" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    PRIMARY KEY ("id"),
    UNIQUE ("name")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."zone"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "regionid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("regionid") REFERENCES "public"."region"("id") ON UPDATE restrict ON
DELETE restrict,
    UNIQUE ("name", "regionid")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."city"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "zoneid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("zoneid") REFERENCES "public"."zone"("id") ON UPDATE restrict ON
DELETE restrict,
    UNIQUE ("name", "zoneid")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."role" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "description" text NOT NULL,
    PRIMARY KEY ("id"),
    UNIQUE ("id"),
    UNIQUE ("name"),
    UNIQUE ("slug")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."distributor" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "logo" text,
    "phone" text NOT NULL,
    "fax" text,
    "email" text,
    "active" boolean NOT NULL DEFAULT true,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "sellon" numeric NOT NULL DEFAULT 0,
    "balance" numeric NOT NULL DEFAULT 0,
    PRIMARY KEY ("id"),
    UNIQUE ("id"),
    UNIQUE ("phone"),
    UNIQUE ("email")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."user" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "username" text NOT NULL,
    "password" text NOT NULL,
    "email" text NOT NULL,
    "phone" text NOT NULL,
    "full_name" text NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "assigned_to" uuid NULL,
    "cityid" uuid NULL,
    "zoneid" uuid NULL,
    "regionid" uuid NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "sellon" numeric NOT NULL DEFAULT 0,
    PRIMARY KEY ("id"),
    UNIQUE ("id"),
    UNIQUE ("username"),
    UNIQUE ("email"),
    UNIQUE ("phone")
);
ALTER TABLE "public"."user"
ADD COLUMN "roleid" uuid NOT NULL;
alter table "public"."user"
add constraint "user_roleid_fkey" foreign key ("roleid") references "public"."role" ("id") on update restrict on
delete restrict;
alter table "public"."user"
add constraint "user_assigned_to_fkey" foreign key ("assigned_to") references "public"."user" ("id") on update restrict on
delete restrict;
alter table "public"."user"
add constraint "user_cityid_fkey" foreign key ("cityid") references "public"."city" ("id") on update restrict on
delete restrict;
alter table "public"."user"
add constraint "user_zoneid_fkey" foreign key ("zoneid") references "public"."zone" ("id") on update restrict on
delete restrict;
alter table "public"."user"
add constraint "user_regionid_fkey" foreign key ("regionid") references "public"."region" ("id") on update restrict on
delete restrict;
ALTER TABLE "public"."user"
ADD COLUMN "distributorid" uuid NULL;
alter table "public"."user"
add constraint "user_distributorid_fkey" foreign key ("distributorid") references "public"."distributor" ("id") on update restrict on
delete restrict;
INSERT INTO role (slug, name, description)
VALUES (
        'Admin',
        'Administrator',
        'System administrator user.'
    ),
    ('Manager', 'Manager', 'Distributor admin user.'),
    ('SM', 'Sales Manager', 'Sales manager user.'),
    ('Sales', 'Sales', 'Sales user.'),
    ('Retailer', 'Retailer', 'Retailer user.');
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."user_log"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "slug" text NOT NULL,
    "info" text NOT NULL,
    "userid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON
DELETE restrict,
    UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."operator" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "description" text NOT NULL,
    "url" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."denomination"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "value" integer NOT NULL DEFAULT 1,
    "operatorid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("operatorid") REFERENCES "public"."operator"("id") ON UPDATE restrict ON
DELETE restrict,
    UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."money"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "userid" uuid NOT NULL,
    "balance" numeric NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON
DELETE restrict,
    UNIQUE ("id"),
    UNIQUE ("userid")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."bank"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "account" text NOT NULL,
    "branch" text NOT NULL,
    "distributorid" uuid,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict,
    UNIQUE ("account")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."deposit"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "ref_number" text,
    "type" text NOT NULL DEFAULT 'BANK',
    "check_no" text,
    "deposited_by" text,
    "amount" numeric NOT NULL,
    "approverid" uuid,
    "depositorid" uuid NOT NULL,
    "distributorid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "date" timestamptz NOT NULL DEFAULT now(),
    "bankid" uuid NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("depositorid") REFERENCES "public"."user" ("id") ON 
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("approverid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("bankid") REFERENCES "public"."bank" ("id") ON
UPDATE restrict ON
DELETE restrict,
    UNIQUE ("ref_number", "depositorid")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."payment"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "ref_number" text,
    "type" text NOT NULL DEFAULT 'BANK',
    "check_no" text,
    "deposited_by" text,
    "amount" numeric NOT NULL DEFAULT 0,
    "distributorid" uuid NOT NULL,
    "creatorid" uuid NOT NULL,
    "approverid" uuid,
    "approved" boolean NOT NULL DEFAULT false,
    "date" timestamptz NOT NULL DEFAULT now(),
    "bankid" uuid NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("creatorid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("approverid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("bankid") REFERENCES "public"."bank" ("id") ON
UPDATE restrict ON
DELETE restrict,
    UNIQUE ("bankid", "ref_number")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."import_log"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "accepted" integer NOT NULL DEFAULT 0,
    "imported" integer NOT NULL DEFAULT 0,
    "exist" integer NOT NULL DEFAULT 0,
    "rejected" integer NOT NULL DEFAULT 0,
    "denominationid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("denominationid") REFERENCES "public"."denomination"("id") ON UPDATE restrict ON
DELETE restrict
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."notification"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "slug" text NOT NULL,
    "info" text NOT NULL,
    "type" text NOT NULL DEFAULT 'Info',
    "seen" boolean NOT NULL DEFAULT false,
    "userid" uuid NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON
DELETE restrict
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."voucher"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "serial" text NOT NULL,
    "voucher" text NOT NULL,
    "expiration_date" timestamptz NOT NULL,
    "denominationid" uuid NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "downloaded_at" timestamptz,
    "printed_at" timestamptz,
    "userid" uuid,
    "distributorid" uuid,
    "sale_batch" text NULL,
    "voucher_batch" text NOT NULL,
    "is_suspended" boolean NOT NULL DEFAULT false,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("denominationid") REFERENCES "public"."denomination"("id") ON UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("userid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor" ("id") ON
UPDATE restrict ON
DELETE restrict,
    UNIQUE ("serial")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."batch_sale"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "batch" text NOT NULL,
    "old_balance" numeric NOT NULL,
    "new_balance" numeric NOT NULL,
    "amount" integer NOT NULL,
    "userid" uuid NOT NULL,
    "denominationid" uuid NOT NULL,
    "distributorid" uuid NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("denominationid") REFERENCES "public"."denomination" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor" ("id") ON
UPDATE restrict ON
DELETE restrict
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."topup"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "approved_at" timestamptz NULL,
    "sellon" numeric NOT NULL DEFAULT 0,
    "amount" numeric NOT NULL DEFAULT 0,
    "userid" uuid NOT NULL,
    "distributorid" uuid NOT NULL,
    "creatorid" uuid NOT NULL,
    "approverid" uuid,
    "airtime" numeric NOT NULL DEFAULT 0,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("userid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("creatorid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("approverid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."dtopup"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "approved_at" timestamptz,
    "sellon" numeric NOT NULL DEFAULT 0,
    "amount" numeric NOT NULL DEFAULT 0,
    "distributorid" uuid NOT NULL,
    "creatorid" uuid NOT NULL,
    "approverid" uuid,
    "airtime" numeric NOT NULL DEFAULT 0,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("creatorid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("approverid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."transfer"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "senderid" uuid NOT NULL,
    "receiverid" uuid NOT NULL,
    "distributorid" uuid NOT NULL,
    "amount" numeric NOT NULL DEFAULT 0,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("senderid") REFERENCES "public"."user"("id") ON UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("receiverid") REFERENCES "public"."user" ("id") ON
UPDATE restrict ON
DELETE restrict,
    FOREIGN KEY ("distributorid") REFERENCES "public"."distributor" ("id") ON
UPDATE restrict ON
DELETE restrict
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."voucher_batch"(
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "batch" text NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "denominationid" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("denominationid") REFERENCES "public"."denomination"("id") ON UPDATE restrict ON DELETE restrict,
    UNIQUE ("denominationid", "batch")
);