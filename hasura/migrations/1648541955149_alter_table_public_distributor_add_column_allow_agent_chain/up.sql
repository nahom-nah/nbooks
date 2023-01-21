alter table "public"."distributor" add column "allow_agent_chain" boolean
 not null default 'false';
