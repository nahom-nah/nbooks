
DROP TABLE "public"."import_log";


DROP TABLE "public"."ddebit";


DROP TABLE "public"."payment";

DROP TABLE "public"."ddetail";

DROP TABLE "public"."dorder";


DROP TABLE "public"."price";


DROP TABLE "public"."debit";

DROP TABLE "public"."repayment";


DROP TABLE "public"."cwallet";


DROP TABLE "public"."company";


DROP TABLE "public"."deposit";

DROP TABLE "public"."loan";


DROP TABLE "public"."detail";

DROP TABLE "public"."order";

DROP TABLE "public"."request";


DROP TABLE "public"."wallet";

DROP TABLE "public"."money";


DROP TABLE "public"."sale";


DROP TABLE "public"."voucher";


DROP TABLE "public"."denomination";


DROP TABLE "public"."operator";


DROP TABLE "public"."user_log";


alter table "public"."user" drop constraint "user_roleid_fkey";

ALTER TABLE "public"."user" DROP COLUMN "roleid";

DROP TABLE "public"."user";

DROP TABLE "public"."role";

DROP TABLE "public"."voucher_batch";

DROP TABLE "public"."bank";
