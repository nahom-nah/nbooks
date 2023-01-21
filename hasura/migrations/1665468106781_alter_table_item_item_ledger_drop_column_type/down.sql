alter table "item"."item_ledger" alter column "type" drop not null;
alter table "item"."item_ledger" add column "type" ledger_types_old;
