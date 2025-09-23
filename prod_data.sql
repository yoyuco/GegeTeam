--
-- PostgreSQL database dump
--

\restrict 11756qqEpMq5OXXaEN5RyhJs8xX5oR0QJudyFmTvaQZoPwgb83Wh9x2qThSriWP

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'b53a5fcc-8ddc-4b05-86a7-c55fad52120d', '{"action":"user_confirmation_requested","actor_id":"e7b02d9a-7c17-4af5-b715-3170cf97ea22","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-09-21 22:57:38.651929+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'cd0e4ada-f471-4f19-a3e5-c7882abd200b', '{"action":"user_signedup","actor_id":"e7b02d9a-7c17-4af5-b715-3170cf97ea22","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-09-21 22:58:01.096315+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '41848c77-ceef-4093-9fdc-92a1fcca99f0', '{"action":"login","actor_id":"e7b02d9a-7c17-4af5-b715-3170cf97ea22","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-09-21 23:54:10.093755+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'c9a22688-e9a3-4a11-89ac-01056bab2ef0', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"yoyuco@gmail.com","user_id":"e7b02d9a-7c17-4af5-b715-3170cf97ea22","user_phone":""}}', '2025-09-22 00:09:10.162111+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '650aaf36-b0e0-4a96-af64-dd996bf07415', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"yoyuco@gmail.com","user_id":"ee80fc07-cdc6-453e-b4b1-7cec6a5db262","user_phone":""}}', '2025-09-22 00:34:33.771078+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '270d56c9-fdaa-4691-8955-8861de087ceb', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"yoyuco@gmail.com","user_id":"ee80fc07-cdc6-453e-b4b1-7cec6a5db262","user_phone":""}}', '2025-09-22 00:35:25.068012+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '5c501427-726c-45eb-abe6-12e58f4e27c5', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"yoyuco@gmail.com","user_id":"6c8856eb-31d1-4e8a-8d69-8ac22c887488","user_phone":""}}', '2025-09-22 00:37:19.247204+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '6181c039-91ec-4199-a790-c612af1c642d', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"yoyuco@gmail.com","user_id":"6c8856eb-31d1-4e8a-8d69-8ac22c887488","user_phone":""}}', '2025-09-22 00:45:25.032881+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '32a32abd-f69d-41a4-9bf8-5b682ad38a66', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"yoyuco@gmail.com","user_id":"8710590d-efde-4c63-99de-aba2014fe944","user_phone":""}}', '2025-09-22 00:45:38.768597+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '028c4065-8095-4ece-bb05-32918c5d16da', '{"action":"login","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-09-22 00:50:19.005398+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '374f607b-463c-4c5d-82c7-13b81dc385d9', '{"action":"logout","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-09-22 00:59:22.761211+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '508f1293-8b35-410d-9f27-a61ff851e152', '{"action":"login","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-09-22 00:59:37.80765+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '04cc756d-f591-4905-96c2-67189c6a90d8', '{"action":"user_confirmation_requested","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-09-22 01:02:39.336309+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '5ccd4fb8-4f58-4b59-a5e3-cd1696f95d6c', '{"action":"user_signedup","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-09-22 01:03:12.289442+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'b21c7120-d489-4b76-b027-dcf0a24edf59', '{"action":"login","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-09-22 01:03:18.69462+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'f6cd9138-ca2d-472f-9f00-6e9d43c09553', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 01:58:17.169743+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '8279d387-f812-44d5-a314-0c62d6c5e2e2', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 01:58:17.184627+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '81c679b8-ecd5-4897-99aa-4baaf4355635', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 02:01:46.869458+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '56b699c7-d658-4877-a1e1-b5eff7a8018f', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 02:01:46.872063+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '09827f49-4c41-432e-8c94-7031f0aaa59c', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 02:56:55.487348+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '604458dd-11f4-431a-b9dc-94e176187023', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 02:56:55.492943+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '7dc44923-8c27-4440-a3e9-3e8d53d8f6eb', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 03:55:31.424825+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '15313744-add9-4bf8-a124-6db22ebcec1f', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 03:55:31.434778+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '8f4c6ab8-ae84-4495-9c35-8174c679db8f', '{"action":"logout","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-09-22 04:02:04.769648+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'd7ca38c2-6dd0-4dca-a4c5-6ecf427513c9', '{"action":"login","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-09-22 04:02:11.165947+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '9c191528-2af4-485d-bcb0-3eaf69d94fff', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 04:45:52.924167+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '78580b3c-ebac-4619-a727-52e94d91bd77', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 04:45:52.937457+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'f0108a76-727f-46d4-8ee1-3cb24ebd9ca6', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 05:00:52.918256+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '6a9b7f9e-a858-4149-8ce4-f58bca18dd9e', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 05:00:52.919414+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'd4d9475d-39bf-4dd1-b5c8-a3cdce506847', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 05:44:04.948202+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'cfef0681-b100-41b5-886f-41d2e670bdf2', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 05:44:04.962874+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '7550cceb-6697-4711-a727-c2c617d1b5bd', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 06:42:05.002422+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '10a74a8b-d0e7-44fb-a4ad-08bc21970ae6', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 06:42:05.018166+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'd84c5e22-2415-4a6c-b87e-3748ba6b510e', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 07:40:05.001239+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '4c2b1594-e0b5-4549-9ae4-978e11161e86', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 07:40:05.01919+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '9f99b601-5564-4bc3-b4a3-57d5daa66c2f', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 07:45:07.111221+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '30cc4557-a7d3-4850-9fdb-d3c3f4a40c6e', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 07:45:07.120235+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '233872cf-48d7-41a5-a740-ffe6ad9617c9', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 08:38:05.102188+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '788337fe-c8af-4beb-82b4-81f234e56833', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 08:38:05.113519+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'a54edf55-57d4-4f34-a190-44bfc6d56b89', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 09:36:05.124176+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '0ebeaa52-ff35-498b-9592-446983a80a37', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 09:36:05.134974+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '7e106c48-2ac1-4869-bbc5-8dfb5c4ab580', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 10:34:05.279236+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '5a529aca-e57d-411a-84af-4ced0a732d6f', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 10:34:05.289946+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'c050d8f3-2119-49ce-b4ce-eb4fb088f793', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 11:32:05.228805+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '2b6cbe74-8e6b-43eb-a3d7-031c9e3fa785', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 11:32:05.236965+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'd5410567-40ac-4aa8-a4b3-8fe969799fa0', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 12:30:05.387754+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'd1971b2a-c80b-4dec-8235-b2c5f1d8105c', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 12:30:05.401394+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'beeb02c2-47a1-470b-be74-fb1be8cf6318', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 13:28:05.300691+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '6b49022c-3b7d-4eb6-97fe-44c398f5a49f', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 13:28:05.316152+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'ae0f2e9c-cfe4-4ce4-8b99-ea4126476e5a', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 13:29:14.757966+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'bf068ef7-1e43-44f1-8cc6-f927b40a7aee', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 13:29:14.759824+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '124205d1-381f-498a-a3f7-550eeac042ad', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 14:26:05.397097+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'e1d4acd7-f2bb-44fd-a6d5-2dc15155b7ca', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 14:26:05.405076+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'a39d7708-79b7-4e60-b8f9-52d76a0c674b', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 15:24:25.501887+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '3ffde798-05eb-43ca-b1ed-4c813d98a19b', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 15:24:25.507862+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'f04a8439-6b9e-407c-a010-c0a87d314a15', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 16:22:26.624+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '48b94ab8-c136-46de-848a-5b86e8897cf2', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 16:22:26.634978+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '84cb7922-7849-4924-95df-1bbd413b0791', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 17:20:26.918888+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'c3709c57-e642-4772-ac69-e63b685a9273', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 17:20:26.93099+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'a5d39eee-01ad-4e9d-adaf-27c6bccd8c9b', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 17:23:20.380051+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '1d0d363d-9d08-4691-877b-f1df6c944867', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 17:23:20.38155+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '9576b538-8afc-41cc-8bf5-4a744794e417', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 18:18:26.754413+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '536d2805-e60d-42b1-aecb-8870a323f5f3', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 18:18:26.771441+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '1ddab082-c658-40e3-a50c-f6a66d5ee034', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 18:21:51.927781+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'ef0e2b46-84e7-44ab-b63a-c0842bdbe7b6', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 18:21:51.932229+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '49a846e7-cb36-4fa3-a8c2-f3c2fe5c4edc', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 19:16:26.767874+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '02da4e60-8b4c-4f6e-b7b7-cf829813befe', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 19:16:26.783159+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '6eab0b91-db82-42f8-b4b3-d657d37d681e', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 19:20:26.177766+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '6a774622-8fca-4c8d-9c96-e3e5c9025618', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 19:20:26.179215+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'fdcef8e8-302a-42b9-bb25-7d15577f38da', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 20:14:27.034277+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'a0c8ca43-5cf3-4d5f-bebf-f48dcc62dcc7', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 20:14:27.053986+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '81421cba-b7b8-4bff-8270-3095264f0413', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 20:19:52.381051+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'b9624fc6-92ad-4285-bb62-e1849a688d65', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 20:19:52.384586+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '31c550b4-e8f1-4a9f-a90f-6f047a8fb505', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 21:12:56.938507+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '572d1ae2-fc07-4a72-a078-77b16f6c6cdf', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 21:12:56.965346+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', 'bb0bc2ec-a78f-4dde-aee4-0ddbe17e9f0a', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 21:18:52.678583+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '1ce04838-1912-4c9c-9917-e35de09aef67', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 21:18:52.680557+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '0f6a5abe-1602-4986-8f79-16a13c040634', '{"action":"token_refreshed","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 22:11:27.165439+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '911d39fa-5e30-4000-836d-dbb1477eab4c', '{"action":"token_revoked","actor_id":"4564fd01-dbe8-48c2-b482-03340d6e0e80","actor_username":"vitaminluv1988@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 22:11:27.176591+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '23c2fc5d-172f-4f76-8e37-dc08d319aacd', '{"action":"token_refreshed","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 22:17:52.80268+00', '');
INSERT INTO auth.audit_log_entries VALUES ('00000000-0000-0000-0000-000000000000', '062eea65-3937-4749-a184-116977c9dd26', '{"action":"token_revoked","actor_id":"8710590d-efde-4c63-99de-aba2014fe944","actor_username":"yoyuco@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-09-22 22:17:52.804228+00', '');


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.users VALUES ('00000000-0000-0000-0000-000000000000', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'authenticated', 'authenticated', 'vitaminluv1988@gmail.com', '$2a$10$NUw.0Ok6VjBMlpxl2eA94OWehwg6WC0a.1Kd5zXEo567/A6/UnKdC', '2025-09-22 01:03:12.311884+00', NULL, '', '2025-09-22 01:02:39.339812+00', '', NULL, '', '', NULL, '2025-09-22 01:03:18.698321+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "4564fd01-dbe8-48c2-b482-03340d6e0e80", "email": "vitaminluv1988@gmail.com", "display_name": "GeGeCuli", "email_verified": true, "phone_verified": false}', NULL, '2025-09-22 01:02:39.320534+00', '2025-09-22 22:11:27.19457+00', NULL, NULL, '', '', NULL, DEFAULT, '', 0, NULL, '', NULL, false, NULL, false);
INSERT INTO auth.users VALUES ('00000000-0000-0000-0000-000000000000', '8710590d-efde-4c63-99de-aba2014fe944', 'authenticated', 'authenticated', 'yoyuco@gmail.com', '$2a$10$i8RbP1Y5elwCtI9c0X0U5u7qS.TBlHk9XfzcVBZPBV5alcMi2vNfa', '2025-09-22 00:45:38.771394+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-09-22 04:02:11.168173+00', '{"provider": "email", "providers": ["email"]}', '{"display_name": "Yuko", "email_verified": true}', NULL, '2025-09-22 00:45:38.753932+00', '2025-09-22 22:17:52.808388+00', NULL, NULL, '', '', NULL, DEFAULT, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.identities VALUES ('8710590d-efde-4c63-99de-aba2014fe944', '8710590d-efde-4c63-99de-aba2014fe944', '{"sub": "8710590d-efde-4c63-99de-aba2014fe944", "email": "yoyuco@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2025-09-22 00:45:38.766329+00', '2025-09-22 00:45:38.766389+00', '2025-09-22 00:45:38.766389+00', DEFAULT, '38609a4d-9414-496f-87f1-718a4203d443');
INSERT INTO auth.identities VALUES ('4564fd01-dbe8-48c2-b482-03340d6e0e80', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{"sub": "4564fd01-dbe8-48c2-b482-03340d6e0e80", "email": "vitaminluv1988@gmail.com", "display_name": "GeGeCuli", "email_verified": true, "phone_verified": false}', 'email', '2025-09-22 01:02:39.330754+00', '2025-09-22 01:02:39.330802+00', '2025-09-22 01:02:39.330802+00', DEFAULT, '651049e6-b0ac-4180-aab4-829fc28062bd');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.sessions VALUES ('3daf7a5f-64cf-4f5f-af37-a7549075b008', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 01:03:12.472926+00', '2025-09-22 01:03:12.472926+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', '14.161.34.127', NULL);
INSERT INTO auth.sessions VALUES ('ad6b7b28-ee43-4f1b-8ae2-817dea11283b', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 01:03:18.698404+00', '2025-09-22 22:11:27.202092+00', NULL, 'aal1', NULL, '2025-09-22 22:11:27.200908', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', '14.161.34.127', NULL);
INSERT INTO auth.sessions VALUES ('8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5', '8710590d-efde-4c63-99de-aba2014fe944', '2025-09-22 04:02:11.168248+00', '2025-09-22 22:17:52.810253+00', NULL, 'aal1', NULL, '2025-09-22 22:17:52.81017', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', '14.161.34.127', NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.mfa_amr_claims VALUES ('3daf7a5f-64cf-4f5f-af37-a7549075b008', '2025-09-22 01:03:12.556074+00', '2025-09-22 01:03:12.556074+00', 'otp', '48811f5c-bd42-46ed-be44-15ea0c2a4fc3');
INSERT INTO auth.mfa_amr_claims VALUES ('ad6b7b28-ee43-4f1b-8ae2-817dea11283b', '2025-09-22 01:03:18.702039+00', '2025-09-22 01:03:18.702039+00', 'password', 'c0f984a7-366a-4cf3-b886-d7539c6dc593');
INSERT INTO auth.mfa_amr_claims VALUES ('8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5', '2025-09-22 04:02:11.174808+00', '2025-09-22 04:02:11.174808+00', 'password', '52de8885-b46f-4734-8bd0-b93618aa4665');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 5, 'uestz63kyst7', '4564fd01-dbe8-48c2-b482-03340d6e0e80', false, '2025-09-22 01:03:12.516176+00', '2025-09-22 01:03:12.516176+00', NULL, '3daf7a5f-64cf-4f5f-af37-a7549075b008');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 6, '5iy4wg2fqfep', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 01:03:18.700272+00', '2025-09-22 02:01:46.87375+00', NULL, 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 8, 'erlc5jqpu6qi', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 02:01:46.874943+00', '2025-09-22 04:45:52.939282+00', '5iy4wg2fqfep', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 11, 'gzakgxbcg4my', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 04:02:11.171749+00', '2025-09-22 05:00:52.919979+00', NULL, '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 12, 'yofcm6jz2yge', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 04:45:52.948995+00', '2025-09-22 05:44:04.969662+00', 'erlc5jqpu6qi', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 14, 'v5lzh6cilhse', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 05:44:04.98183+00', '2025-09-22 06:42:05.018844+00', 'yofcm6jz2yge', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 15, 'f3hwewrvca5o', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 06:42:05.025737+00', '2025-09-22 07:40:05.022148+00', 'v5lzh6cilhse', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 13, 'q5plf54oaxyu', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 05:00:52.920701+00', '2025-09-22 07:45:07.120974+00', 'gzakgxbcg4my', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 16, '6tuaze4ievvb', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 07:40:05.0355+00', '2025-09-22 08:38:05.116521+00', 'f3hwewrvca5o', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 18, 'kgtphr3tswfk', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 08:38:05.124302+00', '2025-09-22 09:36:05.135584+00', '6tuaze4ievvb', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 19, 'cicjx6gs2g4o', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 09:36:05.141022+00', '2025-09-22 10:34:05.291659+00', 'kgtphr3tswfk', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 20, 'bvgmxdz3sfrz', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 10:34:05.298062+00', '2025-09-22 11:32:05.238099+00', 'cicjx6gs2g4o', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 21, 'fimj2adgjy64', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 11:32:05.245972+00', '2025-09-22 12:30:05.403728+00', 'bvgmxdz3sfrz', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 22, 'xrmi7xheiw7s', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 12:30:05.415003+00', '2025-09-22 13:28:05.317965+00', 'fimj2adgjy64', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 17, 'yhfpr35pdnjj', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 07:45:07.126407+00', '2025-09-22 13:29:14.760451+00', 'q5plf54oaxyu', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 23, 'xkz5xb6pw7yi', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 13:28:05.33123+00', '2025-09-22 14:26:05.406655+00', 'xrmi7xheiw7s', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 25, 'wpxl2dq6cytv', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 14:26:05.41428+00', '2025-09-22 15:24:25.50845+00', 'xkz5xb6pw7yi', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 26, 'tgrwjgxvo3vd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 15:24:25.518957+00', '2025-09-22 16:22:26.637506+00', 'wpxl2dq6cytv', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 27, 'n3dituhfe24o', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 16:22:26.642946+00', '2025-09-22 17:20:26.933887+00', 'tgrwjgxvo3vd', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 24, '4wbcnhbrmjo5', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 13:29:14.762357+00', '2025-09-22 17:23:20.382155+00', 'yhfpr35pdnjj', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 28, 'avncisohj7uv', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 17:20:26.942952+00', '2025-09-22 18:18:26.774449+00', 'n3dituhfe24o', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 29, 'zqertyek7cn2', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 17:23:20.383927+00', '2025-09-22 18:21:51.932848+00', '4wbcnhbrmjo5', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 30, 'ym5zl5jvvlvd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 18:18:26.787054+00', '2025-09-22 19:16:26.785505+00', 'avncisohj7uv', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 31, 's2rq3wrc26wh', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 18:21:51.93483+00', '2025-09-22 19:20:26.180464+00', 'zqertyek7cn2', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 32, 'zvsz574tj4ub', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 19:16:26.799173+00', '2025-09-22 20:14:27.057418+00', 'ym5zl5jvvlvd', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 33, 'kn4636zjomoa', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 19:20:26.181788+00', '2025-09-22 20:19:52.385175+00', 's2rq3wrc26wh', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 34, 'gjjruzwyzzj7', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 20:14:27.073521+00', '2025-09-22 21:12:56.967189+00', 'zvsz574tj4ub', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 35, '53zbmjoqlm3m', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 20:19:52.389664+00', '2025-09-22 21:18:52.681186+00', 'kn4636zjomoa', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 36, '7vpixhhy53xp', '4564fd01-dbe8-48c2-b482-03340d6e0e80', true, '2025-09-22 21:12:56.986549+00', '2025-09-22 22:11:27.178269+00', 'gjjruzwyzzj7', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 38, '5zldh3a6zoa2', '4564fd01-dbe8-48c2-b482-03340d6e0e80', false, '2025-09-22 22:11:27.189573+00', '2025-09-22 22:11:27.189573+00', '7vpixhhy53xp', 'ad6b7b28-ee43-4f1b-8ae2-817dea11283b');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 37, 'qkh5dwd2sphf', '8710590d-efde-4c63-99de-aba2014fe944', true, '2025-09-22 21:18:52.68308+00', '2025-09-22 22:17:52.804815+00', '53zbmjoqlm3m', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');
INSERT INTO auth.refresh_tokens VALUES ('00000000-0000-0000-0000-000000000000', 39, 'my2rfcrlzbul', '8710590d-efde-4c63-99de-aba2014fe944', false, '2025-09-22 22:17:52.807299+00', '2025-09-22 22:17:52.807299+00', 'qkh5dwd2sphf', '8f9d3ea3-e0d4-4736-9ef3-59278a43a0e5');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.schema_migrations VALUES ('20171026211738');
INSERT INTO auth.schema_migrations VALUES ('20171026211808');
INSERT INTO auth.schema_migrations VALUES ('20171026211834');
INSERT INTO auth.schema_migrations VALUES ('20180103212743');
INSERT INTO auth.schema_migrations VALUES ('20180108183307');
INSERT INTO auth.schema_migrations VALUES ('20180119214651');
INSERT INTO auth.schema_migrations VALUES ('20180125194653');
INSERT INTO auth.schema_migrations VALUES ('00');
INSERT INTO auth.schema_migrations VALUES ('20210710035447');
INSERT INTO auth.schema_migrations VALUES ('20210722035447');
INSERT INTO auth.schema_migrations VALUES ('20210730183235');
INSERT INTO auth.schema_migrations VALUES ('20210909172000');
INSERT INTO auth.schema_migrations VALUES ('20210927181326');
INSERT INTO auth.schema_migrations VALUES ('20211122151130');
INSERT INTO auth.schema_migrations VALUES ('20211124214934');
INSERT INTO auth.schema_migrations VALUES ('20211202183645');
INSERT INTO auth.schema_migrations VALUES ('20220114185221');
INSERT INTO auth.schema_migrations VALUES ('20220114185340');
INSERT INTO auth.schema_migrations VALUES ('20220224000811');
INSERT INTO auth.schema_migrations VALUES ('20220323170000');
INSERT INTO auth.schema_migrations VALUES ('20220429102000');
INSERT INTO auth.schema_migrations VALUES ('20220531120530');
INSERT INTO auth.schema_migrations VALUES ('20220614074223');
INSERT INTO auth.schema_migrations VALUES ('20220811173540');
INSERT INTO auth.schema_migrations VALUES ('20221003041349');
INSERT INTO auth.schema_migrations VALUES ('20221003041400');
INSERT INTO auth.schema_migrations VALUES ('20221011041400');
INSERT INTO auth.schema_migrations VALUES ('20221020193600');
INSERT INTO auth.schema_migrations VALUES ('20221021073300');
INSERT INTO auth.schema_migrations VALUES ('20221021082433');
INSERT INTO auth.schema_migrations VALUES ('20221027105023');
INSERT INTO auth.schema_migrations VALUES ('20221114143122');
INSERT INTO auth.schema_migrations VALUES ('20221114143410');
INSERT INTO auth.schema_migrations VALUES ('20221125140132');
INSERT INTO auth.schema_migrations VALUES ('20221208132122');
INSERT INTO auth.schema_migrations VALUES ('20221215195500');
INSERT INTO auth.schema_migrations VALUES ('20221215195800');
INSERT INTO auth.schema_migrations VALUES ('20221215195900');
INSERT INTO auth.schema_migrations VALUES ('20230116124310');
INSERT INTO auth.schema_migrations VALUES ('20230116124412');
INSERT INTO auth.schema_migrations VALUES ('20230131181311');
INSERT INTO auth.schema_migrations VALUES ('20230322519590');
INSERT INTO auth.schema_migrations VALUES ('20230402418590');
INSERT INTO auth.schema_migrations VALUES ('20230411005111');
INSERT INTO auth.schema_migrations VALUES ('20230508135423');
INSERT INTO auth.schema_migrations VALUES ('20230523124323');
INSERT INTO auth.schema_migrations VALUES ('20230818113222');
INSERT INTO auth.schema_migrations VALUES ('20230914180801');
INSERT INTO auth.schema_migrations VALUES ('20231027141322');
INSERT INTO auth.schema_migrations VALUES ('20231114161723');
INSERT INTO auth.schema_migrations VALUES ('20231117164230');
INSERT INTO auth.schema_migrations VALUES ('20240115144230');
INSERT INTO auth.schema_migrations VALUES ('20240214120130');
INSERT INTO auth.schema_migrations VALUES ('20240306115329');
INSERT INTO auth.schema_migrations VALUES ('20240314092811');
INSERT INTO auth.schema_migrations VALUES ('20240427152123');
INSERT INTO auth.schema_migrations VALUES ('20240612123726');
INSERT INTO auth.schema_migrations VALUES ('20240729123726');
INSERT INTO auth.schema_migrations VALUES ('20240802193726');
INSERT INTO auth.schema_migrations VALUES ('20240806073726');
INSERT INTO auth.schema_migrations VALUES ('20241009103726');
INSERT INTO auth.schema_migrations VALUES ('20250717082212');
INSERT INTO auth.schema_migrations VALUES ('20250731150234');


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: attributes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attributes VALUES ('56d9f108-6422-4910-b68f-210e031aff43', 'ANDARIEL_MAIDEN_OF_ANGUISH', 'Andariel, Maiden of Anguish', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('d1bb8eaa-e1a7-4aef-a593-ee89165188f9', 'ASHAVA_THE_PESTILENT', 'Ashava, the Pestilent', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('e1176af9-9b1d-40e5-ae75-7ee294e4a27c', 'AVARICE_THE_GOLD_CURSED', 'Avarice, the Gold Cursed', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('6f34af70-9a8d-429f-90ac-1b65fcb51e18', 'BELIAL_LORD_OF_LIES', 'Belial, Lord of Lies', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('7d378342-2fde-4f3e-9cee-43af3c31f7ee', 'DURIEL_KING_OF_MAGGOTS', 'Duriel, King of Maggots', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('02b23518-c190-4539-8145-1d72697ded81', 'ECHO_OF_LILITH', 'Echo of Lilith', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('f72080df-6beb-4581-8409-533123c4d62a', 'ECHO_OF_VARSHAN', 'Echo of Varshan', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('84067055-9070-40a7-8082-95d436e96500', 'GRIGOIRE_THE_GALVANIC_SAINT', 'Grigoire, The Galvanic Saint', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('00bd265d-22df-4f61-9a04-25b6a1bb688b', 'HARBINGER_OF_HATRED', 'Harbinger of Hatred', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('6d88afdc-0f17-48cc-8751-cf02bfd9ae2e', 'LORD_ZIR', 'Lord Zir', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('03b756ab-e5bc-4a1f-ab91-94d11740ab68', 'THE_BEAST_IN_THE_ICE', 'The Beast in the Ice', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('3bb26cfe-76cd-42d9-9d62-d0a732291945', 'URIVAR', 'Urivar', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('b48c5c57-e061-4165-94d8-77b39a772a93', 'WANDERING_DEATH_DEATH_GIVEN_LIFE', 'Wandering Death, Death Given Life', 'BOSS_NAME');
INSERT INTO public.attributes VALUES ('7af65381-c729-43e1-a25b-3d25c8978361', 'PINNACLE_BOSS', 'Pinnacle Boss', 'BOSS_TYPE');
INSERT INTO public.attributes VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', 'TORMENT_BOSS', 'Torment Boss', 'BOSS_TYPE');
INSERT INTO public.attributes VALUES ('d204b91b-a42b-406a-ad1f-87088aec42c8', 'WORLD_BOSS', 'World Boss', 'BOSS_TYPE');
INSERT INTO public.attributes VALUES ('023e3d06-47ff-4016-905b-54527a13d636', 'CURRENCY', 'Currency', 'BUSINESS_AREA');
INSERT INTO public.attributes VALUES ('82b5417e-9d4f-48d2-978b-f6ecb451e17b', 'ITEMS', 'Items', 'BUSINESS_AREA');
INSERT INTO public.attributes VALUES ('0e6e5602-8512-4f2c-bb4e-d53c718b68ab', 'SERVICE', 'Service', 'BUSINESS_AREA');
INSERT INTO public.attributes VALUES ('0931ef6f-1848-4a90-8a72-1497bbd318a7', 'DIABLO_4', 'Diablo 4', 'GAME');
INSERT INTO public.attributes VALUES ('4e678a11-0785-461b-9940-2282ab2e839a', 'POE_1', 'Path of Exile 1', 'GAME');
INSERT INTO public.attributes VALUES ('10fb201e-50ff-42bd-9a09-2a42e139cec1', 'POE_2', 'Path of Exile 2', 'GAME');
INSERT INTO public.attributes VALUES ('6ec3c2e0-e771-4d32-96b0-e4bbe19ff7d5', 'MMORPG', 'MMORPG', 'GAME_TYPE');
INSERT INTO public.attributes VALUES ('5bbc16e2-2f16-4387-bb17-3fb3366631e8', 'ALL_STATS', 'All Stats', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('fcd64fc1-9148-45c8-b567-b57976f2422b', 'ARMOR', 'Armor', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('8ebe52b2-7abb-4f62-a6b6-63e1ea26ebca', 'ATK_SPD', 'Atk Spd', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('3a434b78-1639-4390-8adb-a30854711072', 'ATK_SPD_WHILE_BERSERKING', 'Atk Spd while Berserking', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('72e32d9a-5858-45fa-ada3-c4db5ec92ae6', 'COOLDOWN_RD', 'Cooldown RD', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('46e90b54-20bb-4939-b306-e461fcb1465b', 'CORE_SKILLS', 'Core Skills', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('327108e5-6c7b-49bd-9dbc-7eb83a909a89', 'CRIT_CHANCE', 'Crit Chance', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('e011216d-6f2d-49f6-923f-e0a94d610f10', 'CRIT_DMG', 'Crit Dmg', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('76edfabd-4f9b-4358-bfaf-c4560fbf6500', 'DMG', 'Dmg', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('8d8ce133-4579-4bc7-b293-ee826b9ab07b', 'DMG_NEXT_ATK_AFT_STEALTH', 'Dmg Next Atk Aft Stealth', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('3cfe1866-3370-4bdf-8b10-84660d35195b', 'DMG_RD', 'Dmg RD', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('390c1600-2f97-48e1-8c17-7a5dee538b45', 'DMG_RD_WHILE_HEALTHY', 'Dmg RD while Healthy', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('c10cb0f1-30b4-4dc4-9a5c-a3b189906ea7', 'DOT', 'DOT', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('8708da74-4941-40ac-94ac-96dc69e513ca', 'LIFE_ON_HIT', 'Life On Hit', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('388c5442-2ae1-4fef-9ce4-bc55405484ef', 'LUCKY_HIT_CHANCE', 'Lucky Hit Chance', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('83d0fe6b-9c20-4bfb-bcee-4d632325728b', 'LUCKY_HIT_CHANCE_BERSERKING', 'Lucky Hit: Chance Berserking', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('a385314f-43c7-4cad-8f07-2c45c819a970', 'LUCKY_HIT_CHANCE_TO_HEAL', 'Lucky Hit: Chance to Heal', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('6b85e6b7-2e26-4be5-818c-c466d566ca95', 'LUCKY_HIT_PRIMARY_RESOURCE', 'Lucky Hit: Primary Resource', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('19adffe8-7b31-4593-8a71-85ee1b9f802a', 'MAX_LIFE', 'Max Life', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('b8e738ed-e795-4a54-be72-93c916732341', 'MAX_POISON_RES', 'Max Poison Res', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('fc7a7084-3d33-4d00-b939-6127ccf337dc', 'MAX_RES_ALL', 'Max Res All', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('359f4022-4346-4c9c-a980-14ccf294dd79', 'MAX_RESOURCE', 'Max Resource', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('1a8aa996-f330-47ff-84ca-58ec1ee8fdb2', 'MOVE_SPD', 'Move Spd', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('5277c7f0-e5e4-46df-9738-df18c23063c5', 'OVERPOWER_DMG', 'Overpower Dmg', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('76a18e09-44cb-46fb-b3ac-a1b8807f2175', 'RES_ALL', 'Res All', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('2604a23f-9d3f-4098-ada3-c10c4044cb8c', 'RESOURCE_GENERATION', 'Resource Generation', 'ITEM_STATS_SORT');
INSERT INTO public.attributes VALUES ('8e9b4223-728c-4de5-b78c-ade7b2ba0dc2', 'LEVEL', 'Level', 'LEVELING_TYPE');
INSERT INTO public.attributes VALUES ('a8e77847-00bd-44f6-ad63-529822f360b1', 'PARAGON', 'Paragon', 'LEVELING_TYPE');
INSERT INTO public.attributes VALUES ('600c023a-4866-4cae-90a3-4cb11320143f', 'ABSTRUSE_SIGIL', 'Abstruse Sigil', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('c36b2fc9-23bf-4a8c-950d-8fe8391f80d2', 'ANGELBREATH', 'Angelbreath', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('d353d4ce-5512-436b-bcce-6723d042dd0a', 'BALEFUL_FRAGMENT', 'Baleful Fragment', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('944e4092-03f1-4478-bffd-91e62e83e6ed', 'BITEBERRY', 'Biteberry', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('01dfec69-57fd-43b4-8a88-07034748558f', 'BLIGHTSHADE', 'Blightshade', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('5d4218ca-44f6-45a4-a068-4ff1b07bdc25', 'COILING_WARD', 'Coiling Ward', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('18ca7a74-d411-44da-8a6b-5bc71824bae2', 'FORGOTTEN_SOUL', 'Forgotten Soul', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('4728a3b4-6157-4524-a493-973e371b9dff', 'GALLOWVINE', 'Gallowvine', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('01dd31ba-5fe9-403b-815e-8fbe9523416e', 'HOWLER_MOSS', 'Howler Moss', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('396ed81d-4114-485b-bee5-0ce04d41f444', 'IRON_CHUNK', 'Iron Chunk', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('5b6f56c7-d4ac-4a6e-9dee-74c88f02c083', 'LIFESBANE', 'Lifesbane', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('ca567211-21e7-4cea-9545-8c31db27fe3d', 'OBDUCITE', 'Obducite', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('05b335f0-18c9-4be5-81b7-df8f793733cd', 'RAWHIDE', 'Rawhide', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('aefa7d08-456f-4f42-9f12-b0d57f4257c6', 'REDDAMINE', 'Reddamine', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('7d97e3f5-b5fc-4ff0-8d6f-3ec89f295f74', 'RESPLENDENT_SPARK', 'Resplendent Spark', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('f5cd6298-6402-4565-bf51-0e3c1858ee2b', 'RUNESHARD', 'Runeshard', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('e4deb6d2-6051-437f-9f94-652aefa2ad1b', 'SCATTERED_PRISM', 'Scattered Prism', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('275acf05-8b1e-40a4-beeb-d9e9da07f799', 'SIGIL_POWDER', 'Sigil Powder', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('bcf96942-5fe4-4723-8eb9-fc4afbaa12aa', 'VEILED_CRYSTAL', 'Veiled Crystal', 'MATS_NAME');
INSERT INTO public.attributes VALUES ('53ff8777-ec5c-474d-a99a-cd529df2ec3e', 'MATERIALS_CRAFT_GEAR', 'Materials craft Gear', 'MATS_TYPE');
INSERT INTO public.attributes VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', 'MATERIALS_FOR_ALCHEMIST', 'Materials for Alchemist', 'MATS_TYPE');
INSERT INTO public.attributes VALUES ('74e8c7f9-5f5a-450e-b8d1-14b5382c7c6c', 'MATERIALS_FOR_NIGHTMARE', 'Materials for Nightmare', 'MATS_TYPE');
INSERT INTO public.attributes VALUES ('766e9eb8-7a1a-4d7e-8dbb-366514884ce8', 'MATERIALS_FOR_THE_PIT', 'Materials for The Pit', 'MATS_TYPE');
INSERT INTO public.attributes VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', 'MATERIALS_MASTERWORKING', 'Materials Masterworking', 'MATS_TYPE');
INSERT INTO public.attributes VALUES ('7d35cc5f-d6ca-492a-bc22-37997df53b3b', '_1', '+1', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('1ceec1df-1710-48fa-92b9-2cfef74ffa85', '_10', '+10', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('091ca87b-fb73-442c-83cf-5205a4d3bb85', '_11', '+11', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('4270fca4-09fc-4826-8b9f-a7a4cd0b3dec', '_12', '+12', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('31b1aeef-cc49-4dbc-907d-8ea9678361c1', '_2', '+2', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('6f2799aa-0229-4659-b8ba-29be531f1641', '_3', '+3', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('fc0a72f7-2996-4ec3-b4e3-d01b64b29616', '_4', '+4', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('979455a3-d8f3-43b8-b1af-62e4835ad7ee', '_5', '+5', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('a0e67be4-30f0-4842-9e94-8d7de40dbf93', '_6', '+6', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('2d74bac1-2262-4e95-b819-f23657c61dc5', '_7', '+7', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('df15e3f6-719e-437a-8082-69e1e21d4f71', '_8', '+8', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('1ec84ce9-678c-40f2-b52d-f14a90992fdd', '_9', '+9', 'MW_LEVEL');
INSERT INTO public.attributes VALUES ('58dee4d2-ff58-40d4-95c4-2bb9dc797451', 'BLUE_X1', 'Blue (x1)', 'MW_TYPE');
INSERT INTO public.attributes VALUES ('56b08eb2-20d0-4834-9238-49996c43840f', 'ORANGE_X3', 'Orange (x3)', 'MW_TYPE');
INSERT INTO public.attributes VALUES ('10e12878-2e72-4d37-9486-b8c90a0027dd', 'YELLOW_X2', 'Yellow (x2)', 'MW_TYPE');
INSERT INTO public.attributes VALUES ('281d8fb7-36ee-41d5-89fe-3d79ef35cb91', '1GA_RANDOM', '1GA Random', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('7f3cb6ff-462f-4d87-91d6-eee4dc9b2865', '1GA_REQUEST', '1GA Request', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('f9c40d25-9002-48f3-9646-9241b3c8209c', '2GA_RANDOM', '2GA Random', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('56d6712a-9646-44a2-9281-bc3687ff5b83', '2GA_REQUEST', '2GA Request', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('5d768962-bd3c-4cb8-81eb-f089176f5cb7', '3GA_RANDOM', '3GA Random', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('03b69a32-938d-4bf9-9dea-59fe844bb2b9', '3GA_REQUEST', '3GA Request', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('b6ebcc5a-0f0e-4899-ba11-02874d83a62d', '4GA', '4GA', 'MYTHIC_GA_TYPE');
INSERT INTO public.attributes VALUES ('5848b7e6-f891-4c19-8956-914098d894fe', 'AHAVARION_SPEAR_OF_LYCANDER', 'Ahavarion, Spear of Lycander', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('88d12069-ec3e-4301-8198-226d85771d5f', 'ANDARIELS_VISAGE', 'Andariel''s Visage', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('4b4f0cb2-fb5d-481d-9215-eaa4d48180f8', 'DOOMBRINGER', 'Doombringer', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('d83e4a5c-b11d-43de-b7f3-2eaee466e37f', 'HARLEQUIN_CREST', 'Harlequin Crest', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('1a0a419c-341c-4ecc-abf7-29064bc4091d', 'HEIR_OF_PERDITION', 'Heir of Perdition', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('e497091f-1ff3-4c6e-a4ab-fb53a74dd766', 'MELTED_HEART_OF_SELIG', 'Melted Heart of Selig', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('dfcc8ff7-3a45-488d-bc49-71a9085564a4', 'NESEKEM_THE_HERALD', 'Nesekem, the Herald', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('2d6f7b81-9801-4912-bea8-36213d5719ab', 'RING_OF_STARLESS_SKIES', 'Ring of Starless Skies', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('d39b9b07-f15a-42f0-84d5-0d98d568dbe7', 'SHATTERED_VOW', 'Shattered Vow', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('08c591b3-1dcb-40a3-95bf-e68bd808a270', 'SHROUD_OF_FALSE_DEATH', 'Shroud of False Death', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('4d61837f-dfee-4047-a42d-3b1cb439cf86', 'THE_GRANDFATHER', 'The Grandfather', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('b29a270f-6470-42a7-b38c-5a2916e1ec24', 'TYRAELS_MIGHT', 'Tyrael''s Might', 'MYTHIC_NAME');
INSERT INTO public.attributes VALUES ('e1ddeb0a-d863-485e-a34f-058e4dcc937d', 'BASIC', 'Basic', 'PACKAGE_TYPE');
INSERT INTO public.attributes VALUES ('090ecbb9-30e1-43bf-bb15-c99cbc80f141', 'BUILD_SERVICE', 'Build Service', 'PACKAGE_TYPE');
INSERT INTO public.attributes VALUES ('32b4f83d-7099-4a12-940f-dafbc289bf98', 'CUSTOM', 'Custom', 'PACKAGE_TYPE');
INSERT INTO public.attributes VALUES ('660e078f-db99-4682-aac3-04fa252a2a9e', 'DRY_STEPPES', 'Dry Steppes', 'REGIONS_NAME');
INSERT INTO public.attributes VALUES ('cc45d485-cd32-4030-89e9-eb33a25044fd', 'FRACTURED_PEAKS', 'Fractured Peaks', 'REGIONS_NAME');
INSERT INTO public.attributes VALUES ('04fc2285-63df-4605-baea-02272c121399', 'HAWEZAR', 'Hawezar', 'REGIONS_NAME');
INSERT INTO public.attributes VALUES ('7a908682-9e4f-4b37-a923-cbb23faebcaa', 'KEHJISTAN', 'Kehjistan', 'REGIONS_NAME');
INSERT INTO public.attributes VALUES ('095038e6-e566-43fc-a4cb-9c06160c1611', 'NAHANTU', 'Nahantu', 'REGIONS_NAME');
INSERT INTO public.attributes VALUES ('abe57c2a-98d5-42d3-b314-b4f90037c05c', 'SCOSGLEN', 'Scosglen', 'REGIONS_NAME');
INSERT INTO public.attributes VALUES ('a9c41976-fd97-4968-90c7-90bcf8ea9f9d', 'ALTARS_OF_LILITH', 'Altars of Lilith', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('31cab463-dbb7-4a1b-8173-164527b15f9c', 'BOSS', 'Boss', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('f408c856-7ab3-402f-a86b-f38de379baec', 'GENERIC', 'Generic', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('1aae4234-22c4-4eba-8941-46f279edffd0', 'INFERNAL_HORDES', 'Infernal Hordes', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('625a52cc-b7a3-433d-a7ed-593f16f51101', 'LEVELING', 'Leveling', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 'MASTERWORKING', 'Masterworking', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('9f204167-3271-4da1-bf6e-c19467d1f030', 'MATERIALS', 'Materials', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'MYTHIC', 'Mythic', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('0c26e4f6-a6d4-4d33-a6b6-9b64680d2b2a', 'NIGHTMARE', 'Nightmare', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', 'RENOWN', 'Renown', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'THE_PIT', 'The pit', 'SERVICE_KIND');
INSERT INTO public.attributes VALUES ('fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5', 'PILOT', 'Pilot', 'SERVICE_TYPE');
INSERT INTO public.attributes VALUES ('526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6', 'SELFPAY', 'Selfplay', 'SERVICE_TYPE');
INSERT INTO public.attributes VALUES ('a3927a18-9bad-4b5b-a832-25e601fc8f9f', 'ALL', 'All', 'SPECIAL');
INSERT INTO public.attributes VALUES ('bb9f281e-2f65-4b0e-8df5-b7243d3138a3', 'TIER_1', 'Tier 1', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b57b7c63-7692-4f11-b115-704565af966e', 'TIER_10', 'Tier 10', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e351c090-b6be-4e9b-a188-0db2ce7f103d', 'TIER_100', 'Tier 100', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('9313394d-68cd-46be-9fe7-ae58b740b473', 'TIER_101', 'Tier 101', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('caa11549-7993-4ee4-9600-dc2a8860141e', 'TIER_102', 'Tier 102', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f4682723-047b-4324-8b32-0bbe4e304b45', 'TIER_103', 'Tier 103', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5906d963-301a-445e-ba3c-be0b68cc3110', 'TIER_104', 'Tier 104', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d02e56dc-47fe-4b68-8823-9eead42a5940', 'TIER_105', 'Tier 105', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('dfacf8b2-f798-4f88-b0db-fce99955e485', 'TIER_106', 'Tier 106', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('6ab8af6a-168f-4da2-af95-74acd480db43', 'TIER_107', 'Tier 107', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('af995a0f-59d5-4e14-8c5c-3158dae5f9c9', 'TIER_108', 'Tier 108', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('35c3475a-00b6-4c10-b0dc-dc434e1413f1', 'TIER_109', 'Tier 109', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('dfcc695c-4a44-41d3-ab0a-62d55bf9c954', 'TIER_11', 'Tier 11', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('2df71355-58c0-4a4c-bda9-846b3e647f4d', 'TIER_110', 'Tier 110', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('01d6c4b8-1aec-4b05-88a3-7195cbe63916', 'TIER_111', 'Tier 111', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('26cff92d-8b18-4d22-8ec7-4d6364ed1253', 'TIER_112', 'Tier 112', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('8dad3fbc-cc66-42de-801d-04f215f0382e', 'TIER_113', 'Tier 113', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d53b51a4-6629-46e0-8c03-91535eefce28', 'TIER_114', 'Tier 114', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('53b53fdb-2556-468f-ad9b-49f0a494955c', 'TIER_115', 'Tier 115', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5b141d80-fc0f-498c-b4d7-ed40ea8c4753', 'TIER_116', 'Tier 116', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('cbf095ad-9873-407a-b9de-ec2365ecc8b4', 'TIER_117', 'Tier 117', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('af6def0a-0eea-4e6d-87d4-548113d60b77', 'TIER_118', 'Tier 118', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('6262b036-dac0-40a5-85fb-f7ac5009e04e', 'TIER_119', 'Tier 119', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e9de4270-3a2a-4ba7-88d2-110a5ef2de7d', 'TIER_12', 'Tier 12', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('2eb6eea7-3bdb-4edc-9774-5879ec444007', 'TIER_120', 'Tier 120', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('48876a5a-56dd-4141-8935-6e64a422ce91', 'TIER_121', 'Tier 121', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('0c4aaa66-d593-4b35-86df-16689b698114', 'TIER_122', 'Tier 122', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('047ed7de-bf0d-46f5-a963-2560c227b2bd', 'TIER_123', 'Tier 123', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('08114957-b5d1-4794-b884-f22cd5c315e9', 'TIER_124', 'Tier 124', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1b5600a9-a44d-419b-8819-e1084e3f7088', 'TIER_125', 'Tier 125', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('bcb633b8-518b-4807-bc8d-e9faac42f75a', 'TIER_126', 'Tier 126', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('9d0ea3bc-8317-49ca-9a49-55617b4c0a0b', 'TIER_127', 'Tier 127', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b2b4cf60-39aa-46f9-a767-6373494676be', 'TIER_128', 'Tier 128', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('625a6f94-e6fe-4a3d-a31f-1eadead02be7', 'TIER_129', 'Tier 129', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('9558baac-b345-45fa-b230-48d468f3f741', 'TIER_13', 'Tier 13', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('4ebfc710-03c2-40cd-b1f5-2f34d34b8838', 'TIER_130', 'Tier 130', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('18f4a625-0e7d-440d-9695-12eb68ba19ae', 'TIER_131', 'Tier 131', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('79c9a59d-bab5-42e7-9480-a790e1e0af26', 'TIER_132', 'Tier 132', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('a3fbf7da-3edc-45d4-b162-fc6fefe4562d', 'TIER_133', 'Tier 133', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e4900606-5ab5-4122-ba0a-4d31ec3a6e54', 'TIER_134', 'Tier 134', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('2109d014-51a5-45fc-97e0-6446da4153db', 'TIER_135', 'Tier 135', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d5595987-a1a0-4250-94c9-f329ad01043d', 'TIER_136', 'Tier 136', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('8e504f05-34f1-4170-ab4d-1afbe89adae3', 'TIER_137', 'Tier 137', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('41d253f2-dad2-4904-84ce-9a3d108cab32', 'TIER_138', 'Tier 138', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('3a80ee1e-11c3-455f-970f-7e7e74f098c0', 'TIER_139', 'Tier 139', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('ae878ea5-2b62-4e45-967e-646411dcca19', 'TIER_14', 'Tier 14', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e42cb5f3-a4cb-4b5f-9a53-75cbfbb6d732', 'TIER_140', 'Tier 140', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('9654ea42-39cd-40a8-a38c-bf4298e42d6c', 'TIER_141', 'Tier 141', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('a40e64a1-2bfb-404c-9d94-d1c5236a097d', 'TIER_142', 'Tier 142', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('63f3e00c-45f8-4221-84bb-89a4ed11d393', 'TIER_143', 'Tier 143', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('54e22395-4dfd-418d-98ee-05c33f0a47a7', 'TIER_144', 'Tier 144', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f7a5fe57-3836-4a8f-8ee0-91d65ac6f98d', 'TIER_145', 'Tier 145', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('845b1550-da12-4905-ae15-cbc852a9cdcb', 'TIER_146', 'Tier 146', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('18bf4437-380b-4604-b2db-7e31189786e5', 'TIER_147', 'Tier 147', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('bf310a23-00ab-46b8-bb1d-45148a016cdb', 'TIER_148', 'Tier 148', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('4ebfe2f2-6566-48b6-ac1c-dd2b48c29e64', 'TIER_149', 'Tier 149', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('a9a8325f-e879-41ec-94ce-9c38b14b3df6', 'TIER_15', 'Tier 15', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e7920b5c-3a66-4fcc-bf13-4b3e1e6a64a6', 'TIER_150', 'Tier 150', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('07bbe613-26e7-406d-a9ef-b531c76b33ad', 'TIER_16', 'Tier 16', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5fc761b2-dac3-4295-a360-6dfa1d50e529', 'TIER_17', 'Tier 17', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d9106fcd-48ab-4473-9c46-8676182f691f', 'TIER_18', 'Tier 18', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b619ddbb-af82-4fcd-b760-a9936e60c0b9', 'TIER_19', 'Tier 19', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1708823b-2adf-43de-9fbd-146d8532f17d', 'TIER_2', 'Tier 2', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('86217e18-5d20-4bfa-8f57-45ae50603d1c', 'TIER_20', 'Tier 20', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1ca6060a-8f7f-472b-9b36-f16a367cef30', 'TIER_21', 'Tier 21', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e4d8f474-c9fc-4e63-949e-16f7df068e7f', 'TIER_22', 'Tier 22', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1e8d8bbd-7bb9-4336-ae21-8e18622ce2b6', 'TIER_23', 'Tier 23', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f5d76945-ef90-474f-bb3d-08ffb142a9ed', 'TIER_24', 'Tier 24', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('710c9e4a-fcb9-4f06-9cb4-1093f0a0762e', 'TIER_25', 'Tier 25', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d6b8fa3a-5036-44e1-b6d1-1f5f1447b102', 'TIER_26', 'Tier 26', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('dacdcdc4-8eaa-4ef0-b0bd-b61b5d0503c4', 'TIER_27', 'Tier 27', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d83e8881-80e1-497c-b3da-db69c48bd27e', 'TIER_28', 'Tier 28', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('10e95bf0-66c5-40db-88f3-2637657b07a6', 'TIER_29', 'Tier 29', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('01a859b8-069b-454d-8d61-63565d6bc89e', 'TIER_3', 'Tier 3', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('4f87bb48-c2ca-4fe9-8b9f-3495df973392', 'TIER_30', 'Tier 30', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('ead7fb71-4d76-4109-9fbf-901b8e06e59b', 'TIER_31', 'Tier 31', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('189dca77-ed7d-45d1-a086-5f52e5671e4d', 'TIER_32', 'Tier 32', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f9a3b7fd-4608-409a-98eb-3435b4828098', 'TIER_33', 'Tier 33', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('a64a2e72-c176-4a90-ba8f-79764d4ef282', 'TIER_34', 'Tier 34', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('580adc04-ef6a-42e6-8f40-6f893eb95414', 'TIER_35', 'Tier 35', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('4d5fd861-e718-4c58-af61-3a7e107c28c7', 'TIER_36', 'Tier 36', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1631e221-2dc0-41ec-ba31-48f580d29bef', 'TIER_37', 'Tier 37', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('95b1a565-f82c-43cc-8af0-037696680e2f', 'TIER_38', 'Tier 38', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e1a6a872-8517-408d-a27f-9d7450425a67', 'TIER_39', 'Tier 39', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('fbaa3ecb-92ae-4e20-a271-963fa1003c4c', 'TIER_4', 'Tier 4', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b478d530-1c21-4198-8cfb-0d5757afdd19', 'TIER_40', 'Tier 40', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('ff5cac7b-46a4-4436-bc22-ee95c3e10dcc', 'TIER_41', 'Tier 41', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5b3192f3-decf-41a2-a189-829284e64ddc', 'TIER_42', 'Tier 42', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f65c3ef7-f6fd-4e7e-a7f2-ffed353faa97', 'TIER_43', 'Tier 43', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f46cf879-846b-49c1-84a7-c31c46ef3d67', 'TIER_44', 'Tier 44', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('6f7d6aa3-bb6a-44ec-852e-75bf7085913f', 'TIER_45', 'Tier 45', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('0206ad29-6145-428d-9e39-07f0694d141d', 'TIER_46', 'Tier 46', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('cccd0e64-0deb-49fb-8ed7-21f50081fc53', 'TIER_47', 'Tier 47', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d6c85fa0-64b7-438e-828f-bae231b7be3b', 'TIER_48', 'Tier 48', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('aef9bbf4-dfc9-46cf-8726-ce14bb3d3e93', 'TIER_49', 'Tier 49', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('c0f0d110-c63a-4d5e-a39d-2c0a1efc36e9', 'TIER_5', 'Tier 5', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('0ce91c42-bc2e-4129-ae48-f51488d0de1d', 'TIER_50', 'Tier 50', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('fad3a689-a784-4b12-ba6c-be7ec68d449c', 'TIER_51', 'Tier 51', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('96686ec7-140a-4d4a-b09a-63c0794e42e7', 'TIER_52', 'Tier 52', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f963423c-2406-418a-8583-93978cddd1d6', 'TIER_53', 'Tier 53', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('3bad8cf1-cd24-4de9-bb67-0d4100a17a91', 'TIER_54', 'Tier 54', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('7c4f0754-a39a-4d06-ba29-0d66af2915c2', 'TIER_55', 'Tier 55', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('82a75bab-c1d0-439c-9ed9-55ccd4f556fa', 'TIER_56', 'Tier 56', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('eb438aad-152d-411f-a611-ec5e192bbcee', 'TIER_57', 'Tier 57', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('9db3f972-f42f-4718-ae08-49ac4c31962e', 'TIER_58', 'Tier 58', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1b46933c-8a09-445f-b7d9-4b2fd36f3b4b', 'TIER_59', 'Tier 59', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('cc78b9d3-f8ea-4cba-aad0-f9256099d8e7', 'TIER_6', 'Tier 6', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('752f1e6d-28d1-4a50-bae3-7a9a57a62e5c', 'TIER_60', 'Tier 60', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('7afa68bf-f482-46a5-9392-cda276d73be7', 'TIER_61', 'Tier 61', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('00df7caa-1032-439a-93a9-0973bf460614', 'TIER_62', 'Tier 62', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('eea0622a-a459-455f-8a45-fcf33640643f', 'TIER_63', 'Tier 63', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('27cb4948-7095-4ac9-9bab-14dbed7916d5', 'TIER_64', 'Tier 64', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('82557e84-6bcd-4006-8da9-c014b0932d31', 'TIER_65', 'Tier 65', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('7a1bae2f-aeb8-44f1-886c-1104c836e054', 'TIER_66', 'Tier 66', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('c0da4903-a69e-437d-a9d2-cbba7835a851', 'TIER_67', 'Tier 67', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('8f4df64e-813b-4e43-8be4-a1f65d9edf7f', 'TIER_68', 'Tier 68', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('460b81ac-d684-49c1-bd18-336903236ad9', 'TIER_69', 'Tier 69', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('c19f31c6-7cdf-4e93-ab30-6449c910c574', 'TIER_7', 'Tier 7', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('0a1c1638-cd7d-4e72-9632-52562f5ed2f3', 'TIER_70', 'Tier 70', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b70c96be-992c-4609-a82f-3b7a22609a32', 'TIER_71', 'Tier 71', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('7ddaf381-bb48-452a-8cb9-059d1b3fe67d', 'TIER_72', 'Tier 72', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1d45a0dd-578a-496e-bc77-291d1ac52742', 'TIER_73', 'Tier 73', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('3e00a4ee-7133-485a-8698-494919ff49f6', 'TIER_74', 'Tier 74', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b1f249da-9996-41c8-9563-37765a7517a0', 'TIER_75', 'Tier 75', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('8549a94b-50cb-4776-ace7-f613a7eb2346', 'TIER_76', 'Tier 76', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('061980f3-3534-4f6c-80c3-fa88476eb7a2', 'TIER_77', 'Tier 77', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('46aee2f4-f430-4a5c-af10-c65d76b2ca57', 'TIER_78', 'Tier 78', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b6f1ebc8-8e62-4922-a656-6211a8ed85c0', 'TIER_79', 'Tier 79', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('b7251044-f758-4c78-8c4c-a0be80baf7ec', 'TIER_8', 'Tier 8', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('356df366-40bb-4d26-8556-dffdab0f32de', 'TIER_80', 'Tier 80', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('e760bc8c-ac29-4e39-bfe1-a10bb1e95c6e', 'TIER_81', 'Tier 81', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5154937f-aef4-4184-8012-692cce80e8d0', 'TIER_82', 'Tier 82', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('106d5ca6-341b-49d5-a2d6-85e7513e74cb', 'TIER_83', 'Tier 83', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('28e817f2-c4d0-48bf-ba87-89bb808fbcf9', 'TIER_84', 'Tier 84', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('a19cdabc-e9e8-44cd-ba37-d3fa832689f4', 'TIER_85', 'Tier 85', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('1b8d906c-504a-48f4-a425-2f969475e994', 'TIER_86', 'Tier 86', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('dac1af31-2938-4b0c-90d3-312d31176438', 'TIER_87', 'Tier 87', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('9e039700-e24f-4fa4-a214-abec9716ed39', 'TIER_88', 'Tier 88', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f0c64f07-0b03-4be0-ade2-65e1aed1e465', 'TIER_89', 'Tier 89', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f2a977a6-5076-456f-bbb8-bd7901872d91', 'TIER_9', 'Tier 9', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('35e8a41a-b33f-4795-bc95-1eb52182fd2d', 'TIER_90', 'Tier 90', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('f5bba6f9-1e62-4b4b-a0d3-7ac07f09b6ee', 'TIER_91', 'Tier 91', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5fc5c993-5f1b-4c2d-8970-31528e5c3270', 'TIER_92', 'Tier 92', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('8f537f48-7880-4475-95a8-5e5d58ecadbe', 'TIER_93', 'Tier 93', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('997477e4-f5a1-442b-93ba-6d93bc7dea49', 'TIER_94', 'Tier 94', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('149f3703-7f45-4ad1-a26a-683c6b08f5d8', 'TIER_95', 'Tier 95', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('a623dc12-0edc-4759-8002-d501e80aa4c7', 'TIER_96', 'Tier 96', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('045efcb5-57b2-4abc-a0e0-4bd9f8c4d5e4', 'TIER_97', 'Tier 97', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('683c3d01-1a2f-4c53-bedf-03806d5753d7', 'TIER_98', 'Tier 98', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('67fcf46b-c926-4240-bf35-808143a0a662', 'TIER_99', 'Tier 99', 'TIER_DIFFICULTY');
INSERT INTO public.attributes VALUES ('421ab9e9-147c-44b9-98f3-5b663d2349bb', 'TORMENT_I', 'Torment I', 'TORMENT_DIFFICULTY');
INSERT INTO public.attributes VALUES ('79c139d3-882d-4ccb-8753-b24f246d54cb', 'TORMENT_II', 'Torment II', 'TORMENT_DIFFICULTY');
INSERT INTO public.attributes VALUES ('7d853a11-5126-4659-9a03-3ab5509aeacf', 'TORMENT_III', 'Torment III', 'TORMENT_DIFFICULTY');
INSERT INTO public.attributes VALUES ('481f8bc5-aefc-49f9-92c1-7a7bf0f2234c', 'TORMENT_IV', 'Torment IV', 'TORMENT_DIFFICULTY');
INSERT INTO public.attributes VALUES ('5ce0043e-29d0-4c75-8fbf-7a091b40a5d8', 'EXPERT', 'Expert', 'WORLD_DIFFICULTY');
INSERT INTO public.attributes VALUES ('47373b3d-46e1-4500-a076-3b7c73eb9f06', 'HARD', 'Hard', 'WORLD_DIFFICULTY');
INSERT INTO public.attributes VALUES ('af883844-aaea-440f-b215-30a6ce409004', 'NORMAL', 'Normal', 'WORLD_DIFFICULTY');
INSERT INTO public.attributes VALUES ('d1adec3b-f83a-441a-9a17-a9bac5f42292', 'PENITENT', 'Penitent', 'WORLD_DIFFICULTY');


--
-- Data for Name: attribute_relationships; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_relationships VALUES ('625a52cc-b7a3-433d-a7ed-593f16f51101', '8e9b4223-728c-4de5-b78c-ade7b2ba0dc2');
INSERT INTO public.attribute_relationships VALUES ('625a52cc-b7a3-433d-a7ed-593f16f51101', 'a8e77847-00bd-44f6-ad63-529822f360b1');
INSERT INTO public.attribute_relationships VALUES ('7af65381-c729-43e1-a25b-3d25c8978361', '02b23518-c190-4539-8145-1d72697ded81');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '56d9f108-6422-4910-b68f-210e031aff43');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '03b756ab-e5bc-4a1f-ab91-94d11740ab68');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '6f34af70-9a8d-429f-90ac-1b65fcb51e18');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '7d378342-2fde-4f3e-9cee-43af3c31f7ee');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', 'f72080df-6beb-4581-8409-533123c4d62a');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '84067055-9070-40a7-8082-95d436e96500');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '00bd265d-22df-4f61-9a04-25b6a1bb688b');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '6d88afdc-0f17-48cc-8751-cf02bfd9ae2e');
INSERT INTO public.attribute_relationships VALUES ('7ab33cc3-36ad-4af3-9820-9522346fa2f9', '3bb26cfe-76cd-42d9-9d62-d0a732291945');
INSERT INTO public.attribute_relationships VALUES ('d204b91b-a42b-406a-ad1f-87088aec42c8', 'd1bb8eaa-e1a7-4aef-a593-ee89165188f9');
INSERT INTO public.attribute_relationships VALUES ('d204b91b-a42b-406a-ad1f-87088aec42c8', 'e1176af9-9b1d-40e5-ae75-7ee294e4a27c');
INSERT INTO public.attribute_relationships VALUES ('d204b91b-a42b-406a-ad1f-87088aec42c8', 'b48c5c57-e061-4165-94d8-77b39a772a93');
INSERT INTO public.attribute_relationships VALUES ('31cab463-dbb7-4a1b-8173-164527b15f9c', '7af65381-c729-43e1-a25b-3d25c8978361');
INSERT INTO public.attribute_relationships VALUES ('31cab463-dbb7-4a1b-8173-164527b15f9c', '7ab33cc3-36ad-4af3-9820-9522346fa2f9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'bb9f281e-2f65-4b0e-8df5-b7243d3138a3');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1708823b-2adf-43de-9fbd-146d8532f17d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '01a859b8-069b-454d-8d61-63565d6bc89e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'fbaa3ecb-92ae-4e20-a271-963fa1003c4c');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'c0f0d110-c63a-4d5e-a39d-2c0a1efc36e9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'cc78b9d3-f8ea-4cba-aad0-f9256099d8e7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'c19f31c6-7cdf-4e93-ab30-6449c910c574');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b7251044-f758-4c78-8c4c-a0be80baf7ec');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f2a977a6-5076-456f-bbb8-bd7901872d91');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b57b7c63-7692-4f11-b115-704565af966e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'dfcc695c-4a44-41d3-ab0a-62d55bf9c954');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e9de4270-3a2a-4ba7-88d2-110a5ef2de7d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '9558baac-b345-45fa-b230-48d468f3f741');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'ae878ea5-2b62-4e45-967e-646411dcca19');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'a9a8325f-e879-41ec-94ce-9c38b14b3df6');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '07bbe613-26e7-406d-a9ef-b531c76b33ad');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '5fc761b2-dac3-4295-a360-6dfa1d50e529');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd9106fcd-48ab-4473-9c46-8676182f691f');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b619ddbb-af82-4fcd-b760-a9936e60c0b9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '86217e18-5d20-4bfa-8f57-45ae50603d1c');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1ca6060a-8f7f-472b-9b36-f16a367cef30');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e4d8f474-c9fc-4e63-949e-16f7df068e7f');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1e8d8bbd-7bb9-4336-ae21-8e18622ce2b6');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f5d76945-ef90-474f-bb3d-08ffb142a9ed');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '710c9e4a-fcb9-4f06-9cb4-1093f0a0762e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd6b8fa3a-5036-44e1-b6d1-1f5f1447b102');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'dacdcdc4-8eaa-4ef0-b0bd-b61b5d0503c4');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd83e8881-80e1-497c-b3da-db69c48bd27e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '10e95bf0-66c5-40db-88f3-2637657b07a6');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '4f87bb48-c2ca-4fe9-8b9f-3495df973392');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'ead7fb71-4d76-4109-9fbf-901b8e06e59b');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '189dca77-ed7d-45d1-a086-5f52e5671e4d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f9a3b7fd-4608-409a-98eb-3435b4828098');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'a64a2e72-c176-4a90-ba8f-79764d4ef282');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '580adc04-ef6a-42e6-8f40-6f893eb95414');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '4d5fd861-e718-4c58-af61-3a7e107c28c7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1631e221-2dc0-41ec-ba31-48f580d29bef');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '95b1a565-f82c-43cc-8af0-037696680e2f');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e1a6a872-8517-408d-a27f-9d7450425a67');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b478d530-1c21-4198-8cfb-0d5757afdd19');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'ff5cac7b-46a4-4436-bc22-ee95c3e10dcc');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '5b3192f3-decf-41a2-a189-829284e64ddc');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f65c3ef7-f6fd-4e7e-a7f2-ffed353faa97');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f46cf879-846b-49c1-84a7-c31c46ef3d67');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '6f7d6aa3-bb6a-44ec-852e-75bf7085913f');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '0206ad29-6145-428d-9e39-07f0694d141d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'cccd0e64-0deb-49fb-8ed7-21f50081fc53');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd6c85fa0-64b7-438e-828f-bae231b7be3b');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'aef9bbf4-dfc9-46cf-8726-ce14bb3d3e93');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '0ce91c42-bc2e-4129-ae48-f51488d0de1d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'fad3a689-a784-4b12-ba6c-be7ec68d449c');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '96686ec7-140a-4d4a-b09a-63c0794e42e7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f963423c-2406-418a-8583-93978cddd1d6');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '3bad8cf1-cd24-4de9-bb67-0d4100a17a91');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '7c4f0754-a39a-4d06-ba29-0d66af2915c2');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '82a75bab-c1d0-439c-9ed9-55ccd4f556fa');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'eb438aad-152d-411f-a611-ec5e192bbcee');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '9db3f972-f42f-4718-ae08-49ac4c31962e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1b46933c-8a09-445f-b7d9-4b2fd36f3b4b');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '752f1e6d-28d1-4a50-bae3-7a9a57a62e5c');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '7afa68bf-f482-46a5-9392-cda276d73be7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '00df7caa-1032-439a-93a9-0973bf460614');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'eea0622a-a459-455f-8a45-fcf33640643f');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '27cb4948-7095-4ac9-9bab-14dbed7916d5');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '82557e84-6bcd-4006-8da9-c014b0932d31');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '7a1bae2f-aeb8-44f1-886c-1104c836e054');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'c0da4903-a69e-437d-a9d2-cbba7835a851');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '8f4df64e-813b-4e43-8be4-a1f65d9edf7f');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '460b81ac-d684-49c1-bd18-336903236ad9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '0a1c1638-cd7d-4e72-9632-52562f5ed2f3');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b70c96be-992c-4609-a82f-3b7a22609a32');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '7ddaf381-bb48-452a-8cb9-059d1b3fe67d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1d45a0dd-578a-496e-bc77-291d1ac52742');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '3e00a4ee-7133-485a-8698-494919ff49f6');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b1f249da-9996-41c8-9563-37765a7517a0');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '8549a94b-50cb-4776-ace7-f613a7eb2346');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '061980f3-3534-4f6c-80c3-fa88476eb7a2');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '46aee2f4-f430-4a5c-af10-c65d76b2ca57');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b6f1ebc8-8e62-4922-a656-6211a8ed85c0');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '356df366-40bb-4d26-8556-dffdab0f32de');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e760bc8c-ac29-4e39-bfe1-a10bb1e95c6e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '5154937f-aef4-4184-8012-692cce80e8d0');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '106d5ca6-341b-49d5-a2d6-85e7513e74cb');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '28e817f2-c4d0-48bf-ba87-89bb808fbcf9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'a19cdabc-e9e8-44cd-ba37-d3fa832689f4');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1b8d906c-504a-48f4-a425-2f969475e994');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'dac1af31-2938-4b0c-90d3-312d31176438');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '9e039700-e24f-4fa4-a214-abec9716ed39');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f0c64f07-0b03-4be0-ade2-65e1aed1e465');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '35e8a41a-b33f-4795-bc95-1eb52182fd2d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f5bba6f9-1e62-4b4b-a0d3-7ac07f09b6ee');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '5fc5c993-5f1b-4c2d-8970-31528e5c3270');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '8f537f48-7880-4475-95a8-5e5d58ecadbe');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '997477e4-f5a1-442b-93ba-6d93bc7dea49');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '149f3703-7f45-4ad1-a26a-683c6b08f5d8');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'a623dc12-0edc-4759-8002-d501e80aa4c7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '045efcb5-57b2-4abc-a0e0-4bd9f8c4d5e4');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '683c3d01-1a2f-4c53-bedf-03806d5753d7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '67fcf46b-c926-4240-bf35-808143a0a662');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e351c090-b6be-4e9b-a188-0db2ce7f103d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '9313394d-68cd-46be-9fe7-ae58b740b473');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'caa11549-7993-4ee4-9600-dc2a8860141e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f4682723-047b-4324-8b32-0bbe4e304b45');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '5906d963-301a-445e-ba3c-be0b68cc3110');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd02e56dc-47fe-4b68-8823-9eead42a5940');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'dfacf8b2-f798-4f88-b0db-fce99955e485');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '6ab8af6a-168f-4da2-af95-74acd480db43');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'af995a0f-59d5-4e14-8c5c-3158dae5f9c9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '35c3475a-00b6-4c10-b0dc-dc434e1413f1');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '2df71355-58c0-4a4c-bda9-846b3e647f4d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '01d6c4b8-1aec-4b05-88a3-7195cbe63916');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '26cff92d-8b18-4d22-8ec7-4d6364ed1253');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '8dad3fbc-cc66-42de-801d-04f215f0382e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd53b51a4-6629-46e0-8c03-91535eefce28');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '53b53fdb-2556-468f-ad9b-49f0a494955c');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '5b141d80-fc0f-498c-b4d7-ed40ea8c4753');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'cbf095ad-9873-407a-b9de-ec2365ecc8b4');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'af6def0a-0eea-4e6d-87d4-548113d60b77');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '6262b036-dac0-40a5-85fb-f7ac5009e04e');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '2eb6eea7-3bdb-4edc-9774-5879ec444007');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '48876a5a-56dd-4141-8935-6e64a422ce91');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '0c4aaa66-d593-4b35-86df-16689b698114');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '047ed7de-bf0d-46f5-a963-2560c227b2bd');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '08114957-b5d1-4794-b884-f22cd5c315e9');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '1b5600a9-a44d-419b-8819-e1084e3f7088');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'bcb633b8-518b-4807-bc8d-e9faac42f75a');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '9d0ea3bc-8317-49ca-9a49-55617b4c0a0b');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'b2b4cf60-39aa-46f9-a767-6373494676be');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '625a6f94-e6fe-4a3d-a31f-1eadead02be7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '4ebfc710-03c2-40cd-b1f5-2f34d34b8838');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '18f4a625-0e7d-440d-9695-12eb68ba19ae');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '79c9a59d-bab5-42e7-9480-a790e1e0af26');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'a3fbf7da-3edc-45d4-b162-fc6fefe4562d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e4900606-5ab5-4122-ba0a-4d31ec3a6e54');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '2109d014-51a5-45fc-97e0-6446da4153db');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'd5595987-a1a0-4250-94c9-f329ad01043d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '8e504f05-34f1-4170-ab4d-1afbe89adae3');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '41d253f2-dad2-4904-84ce-9a3d108cab32');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '3a80ee1e-11c3-455f-970f-7e7e74f098c0');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e42cb5f3-a4cb-4b5f-9a53-75cbfbb6d732');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '9654ea42-39cd-40a8-a38c-bf4298e42d6c');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'a40e64a1-2bfb-404c-9d94-d1c5236a097d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '63f3e00c-45f8-4221-84bb-89a4ed11d393');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '54e22395-4dfd-418d-98ee-05c33f0a47a7');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'f7a5fe57-3836-4a8f-8ee0-91d65ac6f98d');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '845b1550-da12-4905-ae15-cbc852a9cdcb');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '18bf4437-380b-4604-b2db-7e31189786e5');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'bf310a23-00ab-46b8-bb1d-45148a016cdb');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', '4ebfe2f2-6566-48b6-ac1c-dd2b48c29e64');
INSERT INTO public.attribute_relationships VALUES ('61c705a9-6050-4679-a4c3-cca927716b95', 'e7920b5c-3a66-4fcc-bf13-4b3e1e6a64a6');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', '396ed81d-4114-485b-bee5-0ce04d41f444');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', '05b335f0-18c9-4be5-81b7-df8f793733cd');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', '18ca7a74-d411-44da-8a6b-5bc71824bae2');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', '600c023a-4866-4cae-90a3-4cb11320143f');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', 'd353d4ce-5512-436b-bcce-6723d042dd0a');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', '5d4218ca-44f6-45a4-a068-4ff1b07bdc25');
INSERT INTO public.attribute_relationships VALUES ('a92d4122-337d-4bcd-a015-8660e0461d64', 'ca567211-21e7-4cea-9545-8c31db27fe3d');
INSERT INTO public.attribute_relationships VALUES ('53ff8777-ec5c-474d-a99a-cd529df2ec3e', 'e4deb6d2-6051-437f-9f94-652aefa2ad1b');
INSERT INTO public.attribute_relationships VALUES ('53ff8777-ec5c-474d-a99a-cd529df2ec3e', '7d97e3f5-b5fc-4ff0-8d6f-3ec89f295f74');
INSERT INTO public.attribute_relationships VALUES ('53ff8777-ec5c-474d-a99a-cd529df2ec3e', 'c36b2fc9-23bf-4a8c-950d-8fe8391f80d2');
INSERT INTO public.attribute_relationships VALUES ('766e9eb8-7a1a-4d7e-8dbb-366514884ce8', 'f5cd6298-6402-4565-bf51-0e3c1858ee2b');
INSERT INTO public.attribute_relationships VALUES ('74e8c7f9-5f5a-450e-b8d1-14b5382c7c6c', '275acf05-8b1e-40a4-beeb-d9e9da07f799');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', 'c36b2fc9-23bf-4a8c-950d-8fe8391f80d2');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', '944e4092-03f1-4478-bffd-91e62e83e6ed');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', '01dfec69-57fd-43b4-8a88-07034748558f');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', '4728a3b4-6157-4524-a493-973e371b9dff');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', '01dd31ba-5fe9-403b-815e-8fbe9523416e');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', '5b6f56c7-d4ac-4a6e-9dee-74c88f02c083');
INSERT INTO public.attribute_relationships VALUES ('4ae604a0-e577-438c-ba66-566cd86d437d', 'aefa7d08-456f-4f42-9f12-b0d57f4257c6');
INSERT INTO public.attribute_relationships VALUES ('9f204167-3271-4da1-bf6e-c19467d1f030', 'a92d4122-337d-4bcd-a015-8660e0461d64');
INSERT INTO public.attribute_relationships VALUES ('9f204167-3271-4da1-bf6e-c19467d1f030', '53ff8777-ec5c-474d-a99a-cd529df2ec3e');
INSERT INTO public.attribute_relationships VALUES ('0c26e4f6-a6d4-4d33-a6b6-9b64680d2b2a', '421ab9e9-147c-44b9-98f3-5b663d2349bb');
INSERT INTO public.attribute_relationships VALUES ('0c26e4f6-a6d4-4d33-a6b6-9b64680d2b2a', '79c139d3-882d-4ccb-8753-b24f246d54cb');
INSERT INTO public.attribute_relationships VALUES ('0c26e4f6-a6d4-4d33-a6b6-9b64680d2b2a', '7d853a11-5126-4659-9a03-3ab5509aeacf');
INSERT INTO public.attribute_relationships VALUES ('0c26e4f6-a6d4-4d33-a6b6-9b64680d2b2a', '481f8bc5-aefc-49f9-92c1-7a7bf0f2234c');
INSERT INTO public.attribute_relationships VALUES ('1aae4234-22c4-4eba-8941-46f279edffd0', '421ab9e9-147c-44b9-98f3-5b663d2349bb');
INSERT INTO public.attribute_relationships VALUES ('1aae4234-22c4-4eba-8941-46f279edffd0', '79c139d3-882d-4ccb-8753-b24f246d54cb');
INSERT INTO public.attribute_relationships VALUES ('1aae4234-22c4-4eba-8941-46f279edffd0', '7d853a11-5126-4659-9a03-3ab5509aeacf');
INSERT INTO public.attribute_relationships VALUES ('1aae4234-22c4-4eba-8941-46f279edffd0', '481f8bc5-aefc-49f9-92c1-7a7bf0f2234c');
INSERT INTO public.attribute_relationships VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', 'cc45d485-cd32-4030-89e9-eb33a25044fd');
INSERT INTO public.attribute_relationships VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', 'abe57c2a-98d5-42d3-b314-b4f90037c05c');
INSERT INTO public.attribute_relationships VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', '660e078f-db99-4682-aac3-04fa252a2a9e');
INSERT INTO public.attribute_relationships VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', '7a908682-9e4f-4b37-a923-cbb23faebcaa');
INSERT INTO public.attribute_relationships VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', '04fc2285-63df-4605-baea-02272c121399');
INSERT INTO public.attribute_relationships VALUES ('eca5ad39-ad71-4c62-ae2e-368fa3931367', '095038e6-e566-43fc-a4cb-9c06160c1611');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '56b08eb2-20d0-4834-9238-49996c43840f');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '10e12878-2e72-4d37-9486-b8c90a0027dd');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '58dee4d2-ff58-40d4-95c4-2bb9dc797451');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '7d35cc5f-d6ca-492a-bc22-37997df53b3b');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '31b1aeef-cc49-4dbc-907d-8ea9678361c1');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '6f2799aa-0229-4659-b8ba-29be531f1641');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 'fc0a72f7-2996-4ec3-b4e3-d01b64b29616');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '979455a3-d8f3-43b8-b1af-62e4835ad7ee');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 'a0e67be4-30f0-4842-9e94-8d7de40dbf93');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '2d74bac1-2262-4e95-b819-f23657c61dc5');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 'df15e3f6-719e-437a-8082-69e1e21d4f71');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '1ec84ce9-678c-40f2-b52d-f14a90992fdd');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '1ceec1df-1710-48fa-92b9-2cfef74ffa85');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '091ca87b-fb73-442c-83cf-5205a4d3bb85');
INSERT INTO public.attribute_relationships VALUES ('5aa37a94-5dc3-4f12-ba94-26488ee55bc7', '4270fca4-09fc-4826-8b9f-a7a4cd0b3dec');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '5848b7e6-f891-4c19-8956-914098d894fe');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '88d12069-ec3e-4301-8198-226d85771d5f');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '4b4f0cb2-fb5d-481d-9215-eaa4d48180f8');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'd83e4a5c-b11d-43de-b7f3-2eaee466e37f');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '1a0a419c-341c-4ecc-abf7-29064bc4091d');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'e497091f-1ff3-4c6e-a4ab-fb53a74dd766');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'dfcc8ff7-3a45-488d-bc49-71a9085564a4');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '2d6f7b81-9801-4912-bea8-36213d5719ab');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'd39b9b07-f15a-42f0-84d5-0d98d568dbe7');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '08c591b3-1dcb-40a3-95bf-e68bd808a270');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '4d61837f-dfee-4047-a42d-3b1cb439cf86');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'b29a270f-6470-42a7-b38c-5a2916e1ec24');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '281d8fb7-36ee-41d5-89fe-3d79ef35cb91');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '7f3cb6ff-462f-4d87-91d6-eee4dc9b2865');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'f9c40d25-9002-48f3-9646-9241b3c8209c');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '56d6712a-9646-44a2-9281-bc3687ff5b83');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '5d768962-bd3c-4cb8-81eb-f089176f5cb7');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', '03b69a32-938d-4bf9-9dea-59fe844bb2b9');
INSERT INTO public.attribute_relationships VALUES ('f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 'b6ebcc5a-0f0e-4899-ba11-02874d83a62d');
INSERT INTO public.attribute_relationships VALUES ('4d61837f-dfee-4047-a42d-3b1cb439cf86', '5bbc16e2-2f16-4387-bb17-3fb3366631e8');
INSERT INTO public.attribute_relationships VALUES ('08c591b3-1dcb-40a3-95bf-e68bd808a270', '5bbc16e2-2f16-4387-bb17-3fb3366631e8');
INSERT INTO public.attribute_relationships VALUES ('dfcc8ff7-3a45-488d-bc49-71a9085564a4', '5bbc16e2-2f16-4387-bb17-3fb3366631e8');
INSERT INTO public.attribute_relationships VALUES ('4b4f0cb2-fb5d-481d-9215-eaa4d48180f8', '5bbc16e2-2f16-4387-bb17-3fb3366631e8');
INSERT INTO public.attribute_relationships VALUES ('88d12069-ec3e-4301-8198-226d85771d5f', '5bbc16e2-2f16-4387-bb17-3fb3366631e8');
INSERT INTO public.attribute_relationships VALUES ('5848b7e6-f891-4c19-8956-914098d894fe', '5bbc16e2-2f16-4387-bb17-3fb3366631e8');
INSERT INTO public.attribute_relationships VALUES ('b29a270f-6470-42a7-b38c-5a2916e1ec24', '1a8aa996-f330-47ff-84ca-58ec1ee8fdb2');
INSERT INTO public.attribute_relationships VALUES ('e497091f-1ff3-4c6e-a4ab-fb53a74dd766', '1a8aa996-f330-47ff-84ca-58ec1ee8fdb2');
INSERT INTO public.attribute_relationships VALUES ('1a0a419c-341c-4ecc-abf7-29064bc4091d', '1a8aa996-f330-47ff-84ca-58ec1ee8fdb2');
INSERT INTO public.attribute_relationships VALUES ('5848b7e6-f891-4c19-8956-914098d894fe', '1a8aa996-f330-47ff-84ca-58ec1ee8fdb2');
INSERT INTO public.attribute_relationships VALUES ('b29a270f-6470-42a7-b38c-5a2916e1ec24', '76a18e09-44cb-46fb-b3ac-a1b8807f2175');
INSERT INTO public.attribute_relationships VALUES ('5848b7e6-f891-4c19-8956-914098d894fe', '76a18e09-44cb-46fb-b3ac-a1b8807f2175');
INSERT INTO public.attribute_relationships VALUES ('5848b7e6-f891-4c19-8956-914098d894fe', '6b85e6b7-2e26-4be5-818c-c466d566ca95');
INSERT INTO public.attribute_relationships VALUES ('88d12069-ec3e-4301-8198-226d85771d5f', '8708da74-4941-40ac-94ac-96dc69e513ca');
INSERT INTO public.attribute_relationships VALUES ('88d12069-ec3e-4301-8198-226d85771d5f', 'b8e738ed-e795-4a54-be72-93c916732341');
INSERT INTO public.attribute_relationships VALUES ('b29a270f-6470-42a7-b38c-5a2916e1ec24', '3cfe1866-3370-4bdf-8b10-84660d35195b');
INSERT INTO public.attribute_relationships VALUES ('4b4f0cb2-fb5d-481d-9215-eaa4d48180f8', '3cfe1866-3370-4bdf-8b10-84660d35195b');
INSERT INTO public.attribute_relationships VALUES ('4b4f0cb2-fb5d-481d-9215-eaa4d48180f8', 'a385314f-43c7-4cad-8f07-2c45c819a970');
INSERT INTO public.attribute_relationships VALUES ('4d61837f-dfee-4047-a42d-3b1cb439cf86', '19adffe8-7b31-4593-8a71-85ee1b9f802a');
INSERT INTO public.attribute_relationships VALUES ('08c591b3-1dcb-40a3-95bf-e68bd808a270', '19adffe8-7b31-4593-8a71-85ee1b9f802a');
INSERT INTO public.attribute_relationships VALUES ('d39b9b07-f15a-42f0-84d5-0d98d568dbe7', '19adffe8-7b31-4593-8a71-85ee1b9f802a');
INSERT INTO public.attribute_relationships VALUES ('dfcc8ff7-3a45-488d-bc49-71a9085564a4', '19adffe8-7b31-4593-8a71-85ee1b9f802a');
INSERT INTO public.attribute_relationships VALUES ('d83e4a5c-b11d-43de-b7f3-2eaee466e37f', '19adffe8-7b31-4593-8a71-85ee1b9f802a');
INSERT INTO public.attribute_relationships VALUES ('4b4f0cb2-fb5d-481d-9215-eaa4d48180f8', '19adffe8-7b31-4593-8a71-85ee1b9f802a');
INSERT INTO public.attribute_relationships VALUES ('d83e4a5c-b11d-43de-b7f3-2eaee466e37f', '72e32d9a-5858-45fa-ada3-c4db5ec92ae6');
INSERT INTO public.attribute_relationships VALUES ('4d61837f-dfee-4047-a42d-3b1cb439cf86', '359f4022-4346-4c9c-a980-14ccf294dd79');
INSERT INTO public.attribute_relationships VALUES ('d83e4a5c-b11d-43de-b7f3-2eaee466e37f', '359f4022-4346-4c9c-a980-14ccf294dd79');
INSERT INTO public.attribute_relationships VALUES ('d83e4a5c-b11d-43de-b7f3-2eaee466e37f', 'fcd64fc1-9148-45c8-b567-b57976f2422b');
INSERT INTO public.attribute_relationships VALUES ('2d6f7b81-9801-4912-bea8-36213d5719ab', '327108e5-6c7b-49bd-9dbc-7eb83a909a89');
INSERT INTO public.attribute_relationships VALUES ('1a0a419c-341c-4ecc-abf7-29064bc4091d', '327108e5-6c7b-49bd-9dbc-7eb83a909a89');
INSERT INTO public.attribute_relationships VALUES ('2d6f7b81-9801-4912-bea8-36213d5719ab', '388c5442-2ae1-4fef-9ce4-bc55405484ef');
INSERT INTO public.attribute_relationships VALUES ('e497091f-1ff3-4c6e-a4ab-fb53a74dd766', '388c5442-2ae1-4fef-9ce4-bc55405484ef');
INSERT INTO public.attribute_relationships VALUES ('1a0a419c-341c-4ecc-abf7-29064bc4091d', '388c5442-2ae1-4fef-9ce4-bc55405484ef');
INSERT INTO public.attribute_relationships VALUES ('2d6f7b81-9801-4912-bea8-36213d5719ab', '46e90b54-20bb-4939-b306-e461fcb1465b');
INSERT INTO public.attribute_relationships VALUES ('1a0a419c-341c-4ecc-abf7-29064bc4091d', '46e90b54-20bb-4939-b306-e461fcb1465b');
INSERT INTO public.attribute_relationships VALUES ('e497091f-1ff3-4c6e-a4ab-fb53a74dd766', '390c1600-2f97-48e1-8c17-7a5dee538b45');
INSERT INTO public.attribute_relationships VALUES ('08c591b3-1dcb-40a3-95bf-e68bd808a270', '2604a23f-9d3f-4098-ada3-c10c4044cb8c');
INSERT INTO public.attribute_relationships VALUES ('e497091f-1ff3-4c6e-a4ab-fb53a74dd766', '2604a23f-9d3f-4098-ada3-c10c4044cb8c');
INSERT INTO public.attribute_relationships VALUES ('dfcc8ff7-3a45-488d-bc49-71a9085564a4', 'e011216d-6f2d-49f6-923f-e0a94d610f10');
INSERT INTO public.attribute_relationships VALUES ('dfcc8ff7-3a45-488d-bc49-71a9085564a4', '5277c7f0-e5e4-46df-9738-df18c23063c5');
INSERT INTO public.attribute_relationships VALUES ('2d6f7b81-9801-4912-bea8-36213d5719ab', '8ebe52b2-7abb-4f62-a6b6-63e1ea26ebca');
INSERT INTO public.attribute_relationships VALUES ('88d12069-ec3e-4301-8198-226d85771d5f', '8ebe52b2-7abb-4f62-a6b6-63e1ea26ebca');
INSERT INTO public.attribute_relationships VALUES ('d39b9b07-f15a-42f0-84d5-0d98d568dbe7', '83d0fe6b-9c20-4bfb-bcee-4d632325728b');
INSERT INTO public.attribute_relationships VALUES ('d39b9b07-f15a-42f0-84d5-0d98d568dbe7', '3a434b78-1639-4390-8adb-a30854711072');
INSERT INTO public.attribute_relationships VALUES ('d39b9b07-f15a-42f0-84d5-0d98d568dbe7', 'c10cb0f1-30b4-4dc4-9a5c-a3b189906ea7');
INSERT INTO public.attribute_relationships VALUES ('08c591b3-1dcb-40a3-95bf-e68bd808a270', '8d8ce133-4579-4bc7-b293-ee826b9ab07b');
INSERT INTO public.attribute_relationships VALUES ('4d61837f-dfee-4047-a42d-3b1cb439cf86', '76edfabd-4f9b-4358-bfaf-c4560fbf6500');
INSERT INTO public.attribute_relationships VALUES ('b29a270f-6470-42a7-b38c-5a2916e1ec24', 'fc7a7084-3d33-4d00-b939-6127ccf337dc');
INSERT INTO public.attribute_relationships VALUES ('6ec3c2e0-e771-4d32-96b0-e4bbe19ff7d5', '0931ef6f-1848-4a90-8a72-1497bbd318a7');


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channels VALUES ('8757fc30-4657-48d9-b58e-d9f8a0af3874', 'Discord');
INSERT INTO public.channels VALUES ('305db40c-25cd-4797-85cc-5f30da3f3aa3', 'Eldorado');
INSERT INTO public.channels VALUES ('815d1021-c0d0-4f26-a34f-1036f0a58092', 'Facebook');
INSERT INTO public.channels VALUES ('25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', 'G2G');
INSERT INTO public.channels VALUES ('d99c8a14-decd-44fe-b91a-0eac3f362aa3', 'PlayerAuctions');


--
-- Data for Name: currencies; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.currencies VALUES ('80c5bde6-8031-422e-93a8-2de3c3de7230', 'USD', 'US Dollar');
INSERT INTO public.currencies VALUES ('b148fedf-2eb4-4725-b6e9-59537d1d845a', 'VND', 'Vietnam Dong');


--
-- Data for Name: parties; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parties VALUES ('76647a26-5714-44ec-b2ff-73b3d14dc332', 'customer', 'Anongaming');
INSERT INTO public.parties VALUES ('48554154-abb0-4b76-bf51-fc3013927af1', 'customer', 'G2G_Test1');
INSERT INTO public.parties VALUES ('95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', 'customer', 'Ân Đụt Đụt');


--
-- Data for Name: customer_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.customer_accounts VALUES ('9fd04a40-9a3d-49ab-982c-000f06bb85e8', '76647a26-5714-44ec-b2ff-73b3d14dc332', 'login', 'acc chồng', NULL, 'Hyokae.gaming@gmail.com', 'Kydnlcdang012@');
INSERT INTO public.customer_accounts VALUES ('686893ec-032a-448c-b867-b2133b270011', '48554154-abb0-4b76-bf51-fc3013927af1', 'btag', 'acc chính', 'G2G_Test1', NULL, NULL);
INSERT INTO public.customer_accounts VALUES ('bc34d369-1e99-4bdf-8db6-83854703a9f2', '95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', 'btag', 'Ân Đụt', 'AnDut#6789', NULL, NULL);
INSERT INTO public.customer_accounts VALUES ('51700d4d-3b45-49c5-9503-e1c62d3ce7d4', '95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', 'btag', 'Acc phụ', 'AnDut#8901', NULL, NULL);
INSERT INTO public.customer_accounts VALUES ('e7e6e13b-1a4e-45b6-9f4b-db58fa6f6f64', '76647a26-5714-44ec-b2ff-73b3d14dc332', 'login', 'Acc Vợ', NULL, 'Kaehyo.gaming@gmail.com', 'Kydnlcdang012@');


--
-- Data for Name: debug_log; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.debug_log VALUES (1, '2025-09-22 04:31:05.53158+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (2, '2025-09-22 04:47:07.290901+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (3, '2025-09-22 04:49:20.251405+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (4, '2025-09-22 04:49:58.073216+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (5, '2025-09-22 04:56:51.248375+00', '[finishSession DEBUG] p_activity_rows: [{"delta": 200, "params": {"label": "BELIAL_LORD_OF_LIES"}, "item_id": "be5a5e91-6b88-4f59-b61a-fb260b0d48a3", "kind_code": "ACTIVITY", "start_value": 0, "current_value": 200, "end_proof_url": null, "start_proof_url": null}, {"delta": 200, "params": {"label": "BELIAL_LORD_OF_LIES"}, "item_id": "756f4a4d-91e9-4b98-a198-a2974617cadd", "kind_code": "ACTIVITY", "start_value": 0, "current_value": 200, "end_proof_url": null, "start_proof_url": null}, {"delta": 200, "params": {"label": "BELIAL_LORD_OF_LIES"}, "item_id": "4c0b6f8e-c878-445c-ae75-ce4483c0ec98", "kind_code": "ACTIVITY", "start_value": 0, "current_value": 200, "end_proof_url": null, "start_proof_url": null}]');
INSERT INTO public.debug_log VALUES (6, '2025-09-22 04:58:43.39879+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (7, '2025-09-22 04:59:48.892515+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (8, '2025-09-22 05:07:54.143963+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (9, '2025-09-22 05:08:55.79047+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (10, '2025-09-22 05:09:21.663988+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (11, '2025-09-22 05:09:43.745853+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (12, '2025-09-22 15:16:52.489126+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (13, '2025-09-22 15:20:26.550914+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (14, '2025-09-22 15:21:04.586921+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (15, '2025-09-22 15:22:09.656321+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (16, '2025-09-22 15:23:31.922752+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (17, '2025-09-22 15:40:50.17682+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (18, '2025-09-22 15:44:25.642568+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (19, '2025-09-22 15:45:01.992219+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (20, '2025-09-22 15:48:22.603667+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (21, '2025-09-22 15:48:57.785928+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (22, '2025-09-22 15:56:22.830476+00', '[finishSession DEBUG] p_activity_rows: [{"delta": 200, "params": {"label": "BELIAL_LORD_OF_LIES"}, "item_id": "cc5e09ed-8248-4d85-ad83-f0a963b124eb", "kind_code": "ACTIVITY", "start_value": 0, "current_value": 200, "end_proof_url": null, "start_proof_url": null}, {"delta": 200, "params": {"label": "BELIAL_LORD_OF_LIES"}, "item_id": "499ffbcf-53c1-48cc-9d0d-4332be499dc1", "kind_code": "ACTIVITY", "start_value": 0, "current_value": 200, "end_proof_url": null, "start_proof_url": null}]');
INSERT INTO public.debug_log VALUES (23, '2025-09-22 16:06:00.56211+00', '[finishSession DEBUG] p_activity_rows: []');
INSERT INTO public.debug_log VALUES (24, '2025-09-22 16:20:02.632687+00', '[finishSession DEBUG] p_activity_rows: []');


--
-- Data for Name: level_exp; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.level_exp VALUES (1, 600000);
INSERT INTO public.level_exp VALUES (2, 600000);
INSERT INTO public.level_exp VALUES (3, 610000);
INSERT INTO public.level_exp VALUES (4, 620000);
INSERT INTO public.level_exp VALUES (5, 630000);
INSERT INTO public.level_exp VALUES (6, 640000);
INSERT INTO public.level_exp VALUES (7, 650000);
INSERT INTO public.level_exp VALUES (8, 660000);
INSERT INTO public.level_exp VALUES (9, 670000);
INSERT INTO public.level_exp VALUES (10, 680000);
INSERT INTO public.level_exp VALUES (11, 690000);
INSERT INTO public.level_exp VALUES (12, 700000);
INSERT INTO public.level_exp VALUES (13, 710000);
INSERT INTO public.level_exp VALUES (14, 720000);
INSERT INTO public.level_exp VALUES (15, 730000);
INSERT INTO public.level_exp VALUES (16, 740000);
INSERT INTO public.level_exp VALUES (17, 750000);
INSERT INTO public.level_exp VALUES (18, 760000);
INSERT INTO public.level_exp VALUES (19, 770000);
INSERT INTO public.level_exp VALUES (20, 780000);
INSERT INTO public.level_exp VALUES (21, 790000);
INSERT INTO public.level_exp VALUES (22, 800000);
INSERT INTO public.level_exp VALUES (23, 810000);
INSERT INTO public.level_exp VALUES (24, 820000);
INSERT INTO public.level_exp VALUES (25, 830000);
INSERT INTO public.level_exp VALUES (26, 840000);
INSERT INTO public.level_exp VALUES (27, 850000);
INSERT INTO public.level_exp VALUES (28, 860000);
INSERT INTO public.level_exp VALUES (29, 870000);
INSERT INTO public.level_exp VALUES (30, 880000);
INSERT INTO public.level_exp VALUES (31, 890000);
INSERT INTO public.level_exp VALUES (32, 900000);
INSERT INTO public.level_exp VALUES (33, 910000);
INSERT INTO public.level_exp VALUES (34, 920000);
INSERT INTO public.level_exp VALUES (35, 930000);
INSERT INTO public.level_exp VALUES (36, 940000);
INSERT INTO public.level_exp VALUES (37, 950000);
INSERT INTO public.level_exp VALUES (38, 960000);
INSERT INTO public.level_exp VALUES (39, 970000);
INSERT INTO public.level_exp VALUES (40, 980000);
INSERT INTO public.level_exp VALUES (41, 990000);
INSERT INTO public.level_exp VALUES (42, 1000000);
INSERT INTO public.level_exp VALUES (43, 1010000);
INSERT INTO public.level_exp VALUES (44, 1020000);
INSERT INTO public.level_exp VALUES (45, 1030000);
INSERT INTO public.level_exp VALUES (46, 1040000);
INSERT INTO public.level_exp VALUES (47, 1050000);
INSERT INTO public.level_exp VALUES (48, 1060000);
INSERT INTO public.level_exp VALUES (49, 1070000);
INSERT INTO public.level_exp VALUES (50, 1080000);
INSERT INTO public.level_exp VALUES (51, 1090000);
INSERT INTO public.level_exp VALUES (52, 1100000);
INSERT INTO public.level_exp VALUES (53, 1110000);
INSERT INTO public.level_exp VALUES (54, 1120000);
INSERT INTO public.level_exp VALUES (55, 1130000);
INSERT INTO public.level_exp VALUES (56, 1140000);
INSERT INTO public.level_exp VALUES (57, 1150000);
INSERT INTO public.level_exp VALUES (58, 1160000);
INSERT INTO public.level_exp VALUES (59, 1170000);
INSERT INTO public.level_exp VALUES (60, 1180000);
INSERT INTO public.level_exp VALUES (61, 1190000);
INSERT INTO public.level_exp VALUES (62, 1200000);
INSERT INTO public.level_exp VALUES (63, 1210000);
INSERT INTO public.level_exp VALUES (64, 1220000);
INSERT INTO public.level_exp VALUES (65, 1230000);
INSERT INTO public.level_exp VALUES (66, 1240000);
INSERT INTO public.level_exp VALUES (67, 1250000);
INSERT INTO public.level_exp VALUES (68, 1260000);
INSERT INTO public.level_exp VALUES (69, 1270000);
INSERT INTO public.level_exp VALUES (70, 1280000);
INSERT INTO public.level_exp VALUES (71, 1290000);
INSERT INTO public.level_exp VALUES (72, 1300000);
INSERT INTO public.level_exp VALUES (73, 1310000);
INSERT INTO public.level_exp VALUES (74, 1320000);
INSERT INTO public.level_exp VALUES (75, 1330000);
INSERT INTO public.level_exp VALUES (76, 1340000);
INSERT INTO public.level_exp VALUES (77, 1353850);
INSERT INTO public.level_exp VALUES (78, 1395669);
INSERT INTO public.level_exp VALUES (79, 1438310);
INSERT INTO public.level_exp VALUES (80, 1481780);
INSERT INTO public.level_exp VALUES (81, 1526083);
INSERT INTO public.level_exp VALUES (82, 1571225);
INSERT INTO public.level_exp VALUES (83, 1617210);
INSERT INTO public.level_exp VALUES (84, 1664044);
INSERT INTO public.level_exp VALUES (85, 1711732);
INSERT INTO public.level_exp VALUES (86, 1760280);
INSERT INTO public.level_exp VALUES (87, 1809692);
INSERT INTO public.level_exp VALUES (88, 1859973);
INSERT INTO public.level_exp VALUES (89, 1911128);
INSERT INTO public.level_exp VALUES (90, 1963164);
INSERT INTO public.level_exp VALUES (91, 2016083);
INSERT INTO public.level_exp VALUES (92, 2069892);
INSERT INTO public.level_exp VALUES (93, 2124595);
INSERT INTO public.level_exp VALUES (94, 2180198);
INSERT INTO public.level_exp VALUES (95, 2236704);
INSERT INTO public.level_exp VALUES (96, 2294120);
INSERT INTO public.level_exp VALUES (97, 2352449);
INSERT INTO public.level_exp VALUES (98, 2411697);
INSERT INTO public.level_exp VALUES (99, 2471868);
INSERT INTO public.level_exp VALUES (100, 2532967);
INSERT INTO public.level_exp VALUES (101, 2595000);
INSERT INTO public.level_exp VALUES (102, 2657969);
INSERT INTO public.level_exp VALUES (103, 2721881);
INSERT INTO public.level_exp VALUES (104, 2786739);
INSERT INTO public.level_exp VALUES (105, 2852549);
INSERT INTO public.level_exp VALUES (106, 2919315);
INSERT INTO public.level_exp VALUES (107, 2987042);
INSERT INTO public.level_exp VALUES (108, 3055734);
INSERT INTO public.level_exp VALUES (109, 3125396);
INSERT INTO public.level_exp VALUES (110, 3196032);
INSERT INTO public.level_exp VALUES (111, 3267646);
INSERT INTO public.level_exp VALUES (112, 3340244);
INSERT INTO public.level_exp VALUES (113, 3413830);
INSERT INTO public.level_exp VALUES (114, 3488408);
INSERT INTO public.level_exp VALUES (115, 3563982);
INSERT INTO public.level_exp VALUES (116, 3640558);
INSERT INTO public.level_exp VALUES (117, 3718138);
INSERT INTO public.level_exp VALUES (118, 3796729);
INSERT INTO public.level_exp VALUES (119, 3876333);
INSERT INTO public.level_exp VALUES (120, 3956956);
INSERT INTO public.level_exp VALUES (121, 4038602);
INSERT INTO public.level_exp VALUES (122, 4121274);
INSERT INTO public.level_exp VALUES (123, 4204978);
INSERT INTO public.level_exp VALUES (124, 4289718);
INSERT INTO public.level_exp VALUES (125, 4375497);
INSERT INTO public.level_exp VALUES (126, 4462320);
INSERT INTO public.level_exp VALUES (127, 4550191);
INSERT INTO public.level_exp VALUES (128, 4639114);
INSERT INTO public.level_exp VALUES (129, 4729095);
INSERT INTO public.level_exp VALUES (130, 4820135);
INSERT INTO public.level_exp VALUES (131, 4912241);
INSERT INTO public.level_exp VALUES (132, 5005415);
INSERT INTO public.level_exp VALUES (133, 5099662);
INSERT INTO public.level_exp VALUES (134, 5194987);
INSERT INTO public.level_exp VALUES (135, 5291393);
INSERT INTO public.level_exp VALUES (136, 5388884);
INSERT INTO public.level_exp VALUES (137, 5487464);
INSERT INTO public.level_exp VALUES (138, 5587137);
INSERT INTO public.level_exp VALUES (139, 5687908);
INSERT INTO public.level_exp VALUES (140, 5789780);
INSERT INTO public.level_exp VALUES (141, 5892758);
INSERT INTO public.level_exp VALUES (142, 5996844);
INSERT INTO public.level_exp VALUES (143, 6102044);
INSERT INTO public.level_exp VALUES (144, 6208361);
INSERT INTO public.level_exp VALUES (145, 6315800);
INSERT INTO public.level_exp VALUES (146, 6424363);
INSERT INTO public.level_exp VALUES (147, 6534055);
INSERT INTO public.level_exp VALUES (148, 6644880);
INSERT INTO public.level_exp VALUES (149, 6756841);
INSERT INTO public.level_exp VALUES (150, 6869943);
INSERT INTO public.level_exp VALUES (151, 6984189);
INSERT INTO public.level_exp VALUES (152, 7099584);
INSERT INTO public.level_exp VALUES (153, 7216131);
INSERT INTO public.level_exp VALUES (154, 7333833);
INSERT INTO public.level_exp VALUES (155, 7452695);
INSERT INTO public.level_exp VALUES (156, 7572720);
INSERT INTO public.level_exp VALUES (157, 7693913);
INSERT INTO public.level_exp VALUES (158, 7816277);
INSERT INTO public.level_exp VALUES (159, 7939815);
INSERT INTO public.level_exp VALUES (160, 8064532);
INSERT INTO public.level_exp VALUES (161, 8190430);
INSERT INTO public.level_exp VALUES (162, 8317515);
INSERT INTO public.level_exp VALUES (163, 8445789);
INSERT INTO public.level_exp VALUES (164, 8575257);
INSERT INTO public.level_exp VALUES (165, 8705921);
INSERT INTO public.level_exp VALUES (166, 8837786);
INSERT INTO public.level_exp VALUES (167, 8970855);
INSERT INTO public.level_exp VALUES (168, 9105132);
INSERT INTO public.level_exp VALUES (169, 9240621);
INSERT INTO public.level_exp VALUES (170, 9377325);
INSERT INTO public.level_exp VALUES (171, 9515247);
INSERT INTO public.level_exp VALUES (172, 9654392);
INSERT INTO public.level_exp VALUES (173, 9794763);
INSERT INTO public.level_exp VALUES (174, 9936363);
INSERT INTO public.level_exp VALUES (175, 10079196);
INSERT INTO public.level_exp VALUES (176, 10223266);
INSERT INTO public.level_exp VALUES (177, 10368576);
INSERT INTO public.level_exp VALUES (178, 10515130);
INSERT INTO public.level_exp VALUES (179, 10662932);
INSERT INTO public.level_exp VALUES (180, 10811984);
INSERT INTO public.level_exp VALUES (181, 10962290);
INSERT INTO public.level_exp VALUES (182, 11113854);
INSERT INTO public.level_exp VALUES (183, 11266679);
INSERT INTO public.level_exp VALUES (184, 11420769);
INSERT INTO public.level_exp VALUES (185, 11576128);
INSERT INTO public.level_exp VALUES (186, 11732758);
INSERT INTO public.level_exp VALUES (187, 11890663);
INSERT INTO public.level_exp VALUES (188, 12049847);
INSERT INTO public.level_exp VALUES (189, 12210312);
INSERT INTO public.level_exp VALUES (190, 12372063);
INSERT INTO public.level_exp VALUES (191, 12535103);
INSERT INTO public.level_exp VALUES (192, 12699436);
INSERT INTO public.level_exp VALUES (193, 12865064);
INSERT INTO public.level_exp VALUES (194, 13031991);
INSERT INTO public.level_exp VALUES (195, 13200220);
INSERT INTO public.level_exp VALUES (196, 13369755);
INSERT INTO public.level_exp VALUES (197, 13540599);
INSERT INTO public.level_exp VALUES (198, 13712756);
INSERT INTO public.level_exp VALUES (199, 13886229);
INSERT INTO public.level_exp VALUES (200, 14061021);
INSERT INTO public.level_exp VALUES (201, 14237135);
INSERT INTO public.level_exp VALUES (202, 14493422);
INSERT INTO public.level_exp VALUES (203, 15014600);
INSERT INTO public.level_exp VALUES (204, 15564945);
INSERT INTO public.level_exp VALUES (205, 16145934);
INSERT INTO public.level_exp VALUES (206, 16759110);
INSERT INTO public.level_exp VALUES (207, 17406087);
INSERT INTO public.level_exp VALUES (208, 18088549);
INSERT INTO public.level_exp VALUES (209, 18808257);
INSERT INTO public.level_exp VALUES (210, 19567051);
INSERT INTO public.level_exp VALUES (211, 20366850);
INSERT INTO public.level_exp VALUES (212, 21209659);
INSERT INTO public.level_exp VALUES (213, 22097571);
INSERT INTO public.level_exp VALUES (214, 23032769);
INSERT INTO public.level_exp VALUES (215, 24017532);
INSERT INTO public.level_exp VALUES (216, 25054236);
INSERT INTO public.level_exp VALUES (217, 26145360);
INSERT INTO public.level_exp VALUES (218, 27293489);
INSERT INTO public.level_exp VALUES (219, 28501318);
INSERT INTO public.level_exp VALUES (220, 29771654);
INSERT INTO public.level_exp VALUES (221, 31107427);
INSERT INTO public.level_exp VALUES (222, 32511684);
INSERT INTO public.level_exp VALUES (223, 33987604);
INSERT INTO public.level_exp VALUES (224, 35538497);
INSERT INTO public.level_exp VALUES (225, 37167807);
INSERT INTO public.level_exp VALUES (226, 38879125);
INSERT INTO public.level_exp VALUES (227, 40676184);
INSERT INTO public.level_exp VALUES (228, 42562873);
INSERT INTO public.level_exp VALUES (229, 44543238);
INSERT INTO public.level_exp VALUES (230, 46621487);
INSERT INTO public.level_exp VALUES (231, 48802000);
INSERT INTO public.level_exp VALUES (232, 51089331);
INSERT INTO public.level_exp VALUES (233, 53488216);
INSERT INTO public.level_exp VALUES (234, 56003579);
INSERT INTO public.level_exp VALUES (235, 58640539);
INSERT INTO public.level_exp VALUES (236, 61404416);
INSERT INTO public.level_exp VALUES (237, 64300741);
INSERT INTO public.level_exp VALUES (238, 67335257);
INSERT INTO public.level_exp VALUES (239, 70513933);
INSERT INTO public.level_exp VALUES (240, 73842969);
INSERT INTO public.level_exp VALUES (241, 77328803);
INSERT INTO public.level_exp VALUES (242, 80978120);
INSERT INTO public.level_exp VALUES (243, 84797861);
INSERT INTO public.level_exp VALUES (244, 88795231);
INSERT INTO public.level_exp VALUES (245, 92977707);
INSERT INTO public.level_exp VALUES (246, 97353049);
INSERT INTO public.level_exp VALUES (247, 101929310);
INSERT INTO public.level_exp VALUES (248, 106714842);
INSERT INTO public.level_exp VALUES (249, 111718309);
INSERT INTO public.level_exp VALUES (250, 116948696);
INSERT INTO public.level_exp VALUES (251, 122415321);
INSERT INTO public.level_exp VALUES (252, 128127845);
INSERT INTO public.level_exp VALUES (253, 134096283);
INSERT INTO public.level_exp VALUES (254, 140331014);
INSERT INTO public.level_exp VALUES (255, 146842796);
INSERT INTO public.level_exp VALUES (256, 153642776);
INSERT INTO public.level_exp VALUES (257, 160742504);
INSERT INTO public.level_exp VALUES (258, 168153945);
INSERT INTO public.level_exp VALUES (259, 175889489);
INSERT INTO public.level_exp VALUES (260, 183961971);
INSERT INTO public.level_exp VALUES (261, 192384680);
INSERT INTO public.level_exp VALUES (262, 201171377);
INSERT INTO public.level_exp VALUES (263, 210336304);
INSERT INTO public.level_exp VALUES (264, 219894206);
INSERT INTO public.level_exp VALUES (265, 229860341);
INSERT INTO public.level_exp VALUES (266, 240250499);
INSERT INTO public.level_exp VALUES (267, 251081019);
INSERT INTO public.level_exp VALUES (268, 262368802);
INSERT INTO public.level_exp VALUES (269, 274131333);
INSERT INTO public.level_exp VALUES (270, 286386693);
INSERT INTO public.level_exp VALUES (271, 299153584);
INSERT INTO public.level_exp VALUES (272, 312451343);
INSERT INTO public.level_exp VALUES (273, 326299962);
INSERT INTO public.level_exp VALUES (274, 340720108);
INSERT INTO public.level_exp VALUES (275, 355733144);
INSERT INTO public.level_exp VALUES (276, 371361149);
INSERT INTO public.level_exp VALUES (277, 387626938);
INSERT INTO public.level_exp VALUES (278, 404554087);
INSERT INTO public.level_exp VALUES (279, 422166952);
INSERT INTO public.level_exp VALUES (280, 440490693);
INSERT INTO public.level_exp VALUES (281, 459551299);
INSERT INTO public.level_exp VALUES (282, 479375610);
INSERT INTO public.level_exp VALUES (283, 499991343);
INSERT INTO public.level_exp VALUES (284, 521427119);
INSERT INTO public.level_exp VALUES (285, 543712484);
INSERT INTO public.level_exp VALUES (286, 566877940);
INSERT INTO public.level_exp VALUES (287, 590954971);
INSERT INTO public.level_exp VALUES (288, 615976073);
INSERT INTO public.level_exp VALUES (289, 641974777);
INSERT INTO public.level_exp VALUES (290, 668985686);
INSERT INTO public.level_exp VALUES (291, 697044498);
INSERT INTO public.level_exp VALUES (292, 726188043);
INSERT INTO public.level_exp VALUES (293, 756454310);
INSERT INTO public.level_exp VALUES (294, 787882482);
INSERT INTO public.level_exp VALUES (295, 820512969);
INSERT INTO public.level_exp VALUES (296, 854387440);
INSERT INTO public.level_exp VALUES (297, 889548861);
INSERT INTO public.level_exp VALUES (298, 926041528);
INSERT INTO public.level_exp VALUES (299, 963911104);
INSERT INTO public.level_exp VALUES (300, 1003204659);


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.profiles VALUES ('8710590d-efde-4c63-99de-aba2014fe944', 'Yuko', 'active', '2025-09-22 00:45:38.753609+00', '2025-09-22 00:45:38.753609+00', '8710590d-efde-4c63-99de-aba2014fe944');
INSERT INTO public.profiles VALUES ('4564fd01-dbe8-48c2-b482-03340d6e0e80', 'GeGeCuli', 'active', '2025-09-22 01:02:39.320158+00', '2025-09-22 01:02:39.320158+00', '4564fd01-dbe8-48c2-b482-03340d6e0e80');


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders VALUES ('5be31535-07b1-4241-995c-e853d929963b', 'SELL', 'completed', '95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:13:44.24242+00', 70, NULL, 'DIABLO_4', 'CUSTOM', '', '2025-09-22 15:25:11.829992+00');
INSERT INTO public.orders VALUES ('7c1888a3-0b0b-4185-9097-d4753b985aa8', 'SELL', 'pending_completion', '95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:39:57.5354+00', 77, NULL, 'DIABLO_4', 'BUILD', '', '2025-09-22 15:40:50.17682+00');
INSERT INTO public.orders VALUES ('b80aec45-5abb-46fc-8ccd-18a97b3fefb6', 'SELL', 'pending_completion', '76647a26-5714-44ec-b2ff-73b3d14dc332', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:42:22.753997+00', 77, NULL, 'DIABLO_4', 'BUILD', '', '2025-09-22 15:45:01.992219+00');
INSERT INTO public.orders VALUES ('d8e3320f-34ab-46fa-af9b-2ac46511de9f', 'SELL', 'pending_completion', '76647a26-5714-44ec-b2ff-73b3d14dc332', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:46:16.256208+00', 44, NULL, 'DIABLO_4', 'BUILD', '', '2025-09-22 15:48:57.785928+00');
INSERT INTO public.orders VALUES ('c725d386-5975-4d78-8643-23fe7f2b4650', 'SELL', 'completed', '76647a26-5714-44ec-b2ff-73b3d14dc332', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 01:14:10.922179+00', 500, NULL, 'DIABLO_4', 'BUILD', 'build end game the pit 140, khách sộp, làm cẩn thận', '2025-09-22 05:13:00.655318+00');
INSERT INTO public.orders VALUES ('2f5274f8-ff5a-4972-a15a-965d3bab28e7', 'SELL', 'cancelled', '95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:15:46.02123+00', 75, 'khách bận đòi refund', 'DIABLO_4', 'BASIC', '', '2025-09-22 14:58:20.91986+00');
INSERT INTO public.orders VALUES ('f2447fdf-98be-4f87-aee1-031a79fd6586', 'SELL', 'in_progress', '95dedee5-aa0d-413b-b5f7-f66ea94ca7fc', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:16:21.039699+00', 21, NULL, 'DIABLO_4', 'BASIC', '', '2025-09-22 14:58:50.447711+00');
INSERT INTO public.orders VALUES ('06382e9f-9376-4f94-8e1b-43bc5475fc5c', 'SELL', 'in_progress', '48554154-abb0-4b76-bf51-fc3013927af1', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '8710590d-efde-4c63-99de-aba2014fe944', '2025-09-22 04:32:07.136764+00', 5, NULL, 'DIABLO_4', 'BASIC', '', '2025-09-22 14:59:25.885839+00');
INSERT INTO public.orders VALUES ('14e9fe39-1fe0-4d1a-acfb-9c887714fc5a', 'SELL', 'completed', '76647a26-5714-44ec-b2ff-73b3d14dc332', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:55:09.846932+00', 44, NULL, 'DIABLO_4', 'BASIC', '', '2025-09-22 15:56:53.416048+00');
INSERT INTO public.orders VALUES ('a7e16054-b6e4-480e-a0d6-c573822a4c3c', 'SELL', 'in_progress', '76647a26-5714-44ec-b2ff-73b3d14dc332', '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', '80c5bde6-8031-422e-93a8-2de3c3de7230', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:05:52.390274+00', 20, NULL, 'DIABLO_4', 'BASIC', '', '2025-09-22 16:20:33.675627+00');


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products VALUES ('37dc1e96-f0d3-440c-8a61-d8041052451e', 'Boosting Service', 'SERVICE');


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.product_variants VALUES ('6c9f15e1-cfd4-419c-84d1-41137946a7d1', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-a58035e8-9f38-462d-aca9-8849e381507f', 5, true);
INSERT INTO public.product_variants VALUES ('91defb3b-1d3c-4dc2-99f2-afdc30065ac5', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-ad80a8e0-4d21-4a31-9b69-27fa1687c3a0', 10, true);
INSERT INTO public.product_variants VALUES ('06884185-af8a-4a02-ac36-ebab58becb4f', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-selfplay', 20, true);
INSERT INTO public.product_variants VALUES ('8e0d6cd0-709e-49f5-aff2-b5596b29a7cf', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BUILD-b742dc45-9527-4c7d-beb8-a141c90b5ebd', 500, true);
INSERT INTO public.product_variants VALUES ('d0f34b02-af5b-49f6-9c9a-29eb642c334f', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-pilot', 30, true);
INSERT INTO public.product_variants VALUES ('5f664629-5e3f-488a-94e2-02a21664fc60', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-b8a8b626-5290-4138-b2a9-0cf906fdee76', 5, true);
INSERT INTO public.product_variants VALUES ('6721a751-98c6-4300-93a0-5e2da038fcc9', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-96ce9ade-0c95-465f-863d-6c0263db2734', 75, true);
INSERT INTO public.product_variants VALUES ('cacb9062-27c9-4ec9-8d1e-10dee3fc3978', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-22f760c7-1691-4176-a656-d05aa80e8d4e', 21, true);
INSERT INTO public.product_variants VALUES ('015759c6-fd45-4827-85b3-0b8a16d112c8', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-4e67239f-b09c-4205-bfd9-8792268192cf', 20, true);
INSERT INTO public.product_variants VALUES ('4ae6d1da-2dda-4092-ab73-4749424e4914', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-CUSTOM-910fdf1f-1da4-48fa-b42a-c7341e634f2d', 70, true);
INSERT INTO public.product_variants VALUES ('7163642d-896c-48e1-8cf6-d95025625d16', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BUILD-fef1e18a-7f81-4c45-b85b-85ad0132bda3', 77, true);
INSERT INTO public.product_variants VALUES ('505e11df-7ee3-4d20-9f31-659ffb13d1eb', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BUILD-6b0c4c6e-b6d8-4c5f-8908-54f4102b498d', 77, true);
INSERT INTO public.product_variants VALUES ('be79c704-2a69-43c1-8268-06fb6ff1569e', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BUILD-781f3f1a-71df-4328-ac45-b035184118c2', 44, true);
INSERT INTO public.product_variants VALUES ('711a6b84-b6d2-492e-be62-2ae8db0bf795', '37dc1e96-f0d3-440c-8a61-d8041052451e', 'Service-BASIC-c9ba16d6-28e1-4f95-a31a-d8fe0008f875', 44, true);


--
-- Data for Name: order_lines; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_lines VALUES ('0f442910-726b-4f8a-9419-c3480a842990', '06382e9f-9376-4f94-8e1b-43bc5475fc5c', '5f664629-5e3f-488a-94e2-02a21664fc60', '686893ec-032a-448c-b867-b2133b270011', 1, 5, '2025-09-23 04:31:58+00', NULL, NULL, '00:00:00', NULL);
INSERT INTO public.order_lines VALUES ('8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', 'c725d386-5975-4d78-8643-23fe7f2b4650', 'd0f34b02-af5b-49f6-9c9a-29eb642c334f', '9fd04a40-9a3d-49ab-982c-000f06bb85e8', 1, 500, '2025-09-30 01:14:07+00', NULL, NULL, '00:00:00', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/completion/1758517980444_odc1c9etqcs.png}');
INSERT INTO public.order_lines VALUES ('99845878-ad7d-4520-a213-cfcfbca9b2e6', 'f2447fdf-98be-4f87-aee1-031a79fd6586', 'cacb9062-27c9-4ec9-8d1e-10dee3fc3978', '51700d4d-3b45-49c5-9503-e1c62d3ce7d4', 1, 21, '2025-09-24 05:16:20+00', NULL, NULL, '00:00:00', NULL);
INSERT INTO public.order_lines VALUES ('79479fa1-89a1-464f-987e-ba80d33f0c81', '2f5274f8-ff5a-4972-a15a-965d3bab28e7', '6721a751-98c6-4300-93a0-5e2da038fcc9', 'bc34d369-1e99-4bdf-8db6-83854703a9f2', 1, 75, '2025-09-26 05:15:42+00', NULL, NULL, '00:00:00', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/79479fa1-89a1-464f-987e-ba80d33f0c81/cancellation/1758553099958_zase2w8g2j.png}');
INSERT INTO public.order_lines VALUES ('2ab4011d-7ff1-46ba-be36-c03a73d9f3f6', 'a7e16054-b6e4-480e-a0d6-c573822a4c3c', '015759c6-fd45-4827-85b3-0b8a16d112c8', 'e7e6e13b-1a4e-45b6-9f4b-db58fa6f6f64', 1, 20, '2025-09-30 15:05:50+00', NULL, NULL, '00:00:00', NULL);
INSERT INTO public.order_lines VALUES ('7b637335-aa61-429b-97be-092c438427ee', '5be31535-07b1-4241-995c-e853d929963b', '4ae6d1da-2dda-4092-ab73-4749424e4914', 'bc34d369-1e99-4bdf-8db6-83854703a9f2', 1, 70, '2025-09-25 15:18:58.33949+00', NULL, NULL, '00:05:17.33949', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/completion/1758554711076_vxs42ttfxus.png}');
INSERT INTO public.order_lines VALUES ('88162217-4bce-4014-aec7-466508a9ec43', '7c1888a3-0b0b-4185-9097-d4753b985aa8', '7163642d-896c-48e1-8cf6-d95025625d16', 'bc34d369-1e99-4bdf-8db6-83854703a9f2', 1, 77, '2025-09-30 15:39:55+00', NULL, NULL, '00:00:00', NULL);
INSERT INTO public.order_lines VALUES ('fec9cbcc-7d98-4540-be3e-e29b807cf77d', 'b80aec45-5abb-46fc-8ccd-18a97b3fefb6', '505e11df-7ee3-4d20-9f31-659ffb13d1eb', '9fd04a40-9a3d-49ab-982c-000f06bb85e8', 1, 77, '2025-09-25 15:41:20+00', NULL, NULL, '00:00:00', NULL);
INSERT INTO public.order_lines VALUES ('90e39f2e-280e-41e4-8237-48f57832d653', 'd8e3320f-34ab-46fa-af9b-2ac46511de9f', 'be79c704-2a69-43c1-8268-06fb6ff1569e', '9fd04a40-9a3d-49ab-982c-000f06bb85e8', 1, 44, NULL, NULL, NULL, '00:00:00', NULL);
INSERT INTO public.order_lines VALUES ('a9a86d4e-8b04-4e46-8190-65dfaf5656e9', '14e9fe39-1fe0-4d1a-acfb-9c887714fc5a', '711a6b84-b6d2-492e-be62-2ae8db0bf795', '9fd04a40-9a3d-49ab-982c-000f06bb85e8', 1, 44, '2025-09-30 15:54:54+00', NULL, NULL, '00:00:00', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/completion/1758556612646_e2i3553a5ne.png}');


--
-- Data for Name: order_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_reviews VALUES ('dbd5dc89-1db4-492b-a3a2-0fb4bd8ee4e9', '7b637335-aa61-429b-97be-092c438427ee', 1, NULL, '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/completion/1758554881806_l9xarfthlp.png}', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:28:02.636938+00');


--
-- Data for Name: order_service_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_service_items VALUES ('6bcee3a9-3d3d-4de5-8c41-f5058dfaa126', '90e39f2e-280e-41e4-8237-48f57832d653', '{"attribute_code": "FORGOTTEN_SOUL"}', 15000, '9f204167-3271-4da1-bf6e-c19467d1f030', 16000);
INSERT INTO public.order_service_items VALUES ('ba293e3e-ce8d-472b-b27e-ea4d96616f3b', '90e39f2e-280e-41e4-8237-48f57832d653', '{"attribute_code": "ORANGE_X3"}', 10, '5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 10);
INSERT INTO public.order_service_items VALUES ('3afe836b-e565-4953-93d2-661d0878bbb2', '0f442910-726b-4f8a-9419-c3480a842990', '{"end": 60, "mode": "level", "start": 1}', 59, '625a52cc-b7a3-433d-a7ed-593f16f51101', 0);
INSERT INTO public.order_service_items VALUES ('050dca03-cc40-4c9d-bb43-027304f100a7', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"end": 60, "mode": "level", "start": 1}', 59, '625a52cc-b7a3-433d-a7ed-593f16f51101', 59);
INSERT INTO public.order_service_items VALUES ('e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"end": 300, "mode": "paragon", "start": 1}', 299, '625a52cc-b7a3-433d-a7ed-593f16f51101', 299);
INSERT INTO public.order_service_items VALUES ('be5a5e91-6b88-4f59-b61a-fb260b0d48a3', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"ga_code": "2GA_REQUEST", "ga_note": "Cooldown RD, Max Life", "ga_label": "2GA Request", "item_code": "HARLEQUIN_CREST", "item_label": "Harlequin Crest"}', 1, 'f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 1);
INSERT INTO public.order_service_items VALUES ('756f4a4d-91e9-4b98-a198-a2974617cadd', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"ga_code": "2GA_REQUEST", "ga_note": "Core Skills, Crit Chance", "ga_label": "2GA Request", "item_code": "RING_OF_STARLESS_SKIES", "item_label": "Ring of Starless Skies"}', 1, 'f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 1);
INSERT INTO public.order_service_items VALUES ('4c0b6f8e-c878-445c-ae75-ce4483c0ec98', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"ga_code": "2GA_REQUEST", "ga_note": "All Stats, Max Life", "ga_label": "2GA Request", "item_code": "SHROUD_OF_FALSE_DEATH", "item_label": "Shroud of False Death"}', 1, 'f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 1);
INSERT INTO public.order_service_items VALUES ('e01e7210-8053-4f54-830f-dc51c634154c', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"attribute_code": "FORGOTTEN_SOUL"}', 15000, '9f204167-3271-4da1-bf6e-c19467d1f030', 15000);
INSERT INTO public.order_service_items VALUES ('cc5e09ed-8248-4d85-ad83-f0a963b124eb', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9', '{"ga_code": "2GA_REQUEST", "ga_note": "Max Life, Cooldown RD", "ga_label": "2GA Request", "item_code": "HARLEQUIN_CREST", "item_label": "Harlequin Crest"}', 1, 'f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 1);
INSERT INTO public.order_service_items VALUES ('499ffbcf-53c1-48cc-9d0d-4332be499dc1', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9', '{"ga_code": "1GA_REQUEST", "ga_note": "Max Life", "ga_label": "1GA Request", "item_code": "DOOMBRINGER", "item_label": "Doombringer"}', 1, 'f908d193-0bd4-4be6-b0ee-b86727f8dcc1', 1);
INSERT INTO public.order_service_items VALUES ('6f8542b1-7c2a-47be-922f-d8059d9d8a9c', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', '{"attribute_code": "FORGOTTEN_SOUL"}', 15000, '9f204167-3271-4da1-bf6e-c19467d1f030', 20000);
INSERT INTO public.order_service_items VALUES ('50a08ed9-e6a3-484c-8f7b-ea068255bbee', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"attribute_code": "ORANGE_X3"}', 10, '5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 10);
INSERT INTO public.order_service_items VALUES ('b1e0e3cc-adbf-4949-9992-84b0deccb870', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"attribute_code": "OBDUCITE"}', 350000, '9f204167-3271-4da1-bf6e-c19467d1f030', 1250000);
INSERT INTO public.order_service_items VALUES ('da219c16-9450-4eb9-b456-6257866ea0f4', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '{"attribute_code": "ALL"}', 1, 'eca5ad39-ad71-4c62-ae2e-368fa3931367', 1);
INSERT INTO public.order_service_items VALUES ('7a35a9ea-b99b-42d2-9439-b13920f261c3', '79479fa1-89a1-464f-987e-ba80d33f0c81', '{"end": 300, "mode": "paragon", "start": 259}', 41, '625a52cc-b7a3-433d-a7ed-593f16f51101', 0);
INSERT INTO public.order_service_items VALUES ('774a71a6-c241-4de3-b2e2-ec9d71dc93f6', '99845878-ad7d-4520-a213-cfcfbca9b2e6', '{"end": 60, "mode": "level", "start": 1}', 59, '625a52cc-b7a3-433d-a7ed-593f16f51101', 0);
INSERT INTO public.order_service_items VALUES ('ffcb84f5-c839-4efe-be8c-40f4888ca3b0', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', '{"attribute_code": "OBDUCITE"}', 250000, '9f204167-3271-4da1-bf6e-c19467d1f030', 300000);
INSERT INTO public.order_service_items VALUES ('95af0801-eabc-4d0a-a90d-c26deed08467', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6', '{"end": 60, "mode": "level", "start": 1}', 59, '625a52cc-b7a3-433d-a7ed-593f16f51101', 28);
INSERT INTO public.order_service_items VALUES ('0d01aae9-382e-42fc-aa39-754adfd5f28c', '7b637335-aa61-429b-97be-092c438427ee', '{"end": 60, "mode": "level", "start": 1}', 59, '625a52cc-b7a3-433d-a7ed-593f16f51101', 59);
INSERT INTO public.order_service_items VALUES ('47bcf011-8161-430f-966e-f6b6f2a7c92a', '7b637335-aa61-429b-97be-092c438427ee', '{"end": 150, "mode": "paragon", "start": 1}', 149, '625a52cc-b7a3-433d-a7ed-593f16f51101', 149);
INSERT INTO public.order_service_items VALUES ('e84b5499-2d23-48b3-9d18-347630e09cc1', '7b637335-aa61-429b-97be-092c438427ee', '{"boss_code": "BELIAL_LORD_OF_LIES", "boss_label": "Belial, Lord of Lies"}', 200, '31cab463-dbb7-4a1b-8173-164527b15f9c', 200);
INSERT INTO public.order_service_items VALUES ('47c23563-689a-4fbd-b3a4-134204fb4f34', '88162217-4bce-4014-aec7-466508a9ec43', '{"attribute_code": "ORANGE_X3"}', 10, '5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 10);
INSERT INTO public.order_service_items VALUES ('8fabd6a2-f160-4012-8712-d7184c305648', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', '{"attribute_code": "ORANGE_X3"}', 10, '5aa37a94-5dc3-4f12-ba94-26488ee55bc7', 10);


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.permissions VALUES ('0707495e-ece2-4905-8046-a6e65353e2aa', 'admin:manage_roles', 'Quản lý vai trò và quyền hạn', 'Admin', 'Quản lý nhân viên, vai trò và phân quyền');
INSERT INTO public.permissions VALUES ('827f35cf-67d5-4bcf-9477-bd7f9d82bbe6', 'system:view_audit_logs', 'Xem lịch sử hệ thống (audit logs)', 'Admin', 'Xem lịch sử tất cả các thao tác trên toàn hệ thống');
INSERT INTO public.permissions VALUES ('61c33853-ab38-439d-892e-1dbbe558d26b', 'orders:add_review', 'Can add a review to an order', 'Orders', 'Có thể thêm đánh giá cho một đơn hàng');
INSERT INTO public.permissions VALUES ('98b8f11c-5350-4bac-baae-473424e8f27f', 'orders:cancel', 'Can cancel an order', 'Orders', 'Có thể hủy bỏ một đơn hàng');
INSERT INTO public.permissions VALUES ('a45d15b1-4cf3-4f47-ba7f-182fd1f72b8a', 'orders:complete', 'Can complete an order', 'Orders', 'Có thể đánh dấu một đơn hàng là hoàn thành');
INSERT INTO public.permissions VALUES ('744c5815-e4f6-4073-93c9-19b91447ae4b', 'orders:create', 'Tạo đơn hàng mới', 'Orders', 'Tạo đơn hàng mới');
INSERT INTO public.permissions VALUES ('e0997ce9-f1f9-415d-ba88-9e315a85fa9c', 'orders:edit_details', 'Sửa thông tin chi tiết đơn hàng', 'Orders', 'Sửa thông tin chi tiết của một đơn hàng (deadline, ghi chú, thông tin tài khoản...)');
INSERT INTO public.permissions VALUES ('bfa14d6a-fe62-4664-b3b5-88eea8e2e049', 'orders:override', 'Can override and manage all orders', 'Orders', 'Có thể ghi đè và quản lý tất cả đơn hàng (hoàn thành/hủy của người khác)');
INSERT INTO public.permissions VALUES ('d2c93eae-dcc1-4024-b9fc-1d22b0ca62e0', 'orders:view_all', 'Xem tất cả đơn hàng', 'Orders', 'Xem tất cả các đơn hàng trong hệ thống');
INSERT INTO public.permissions VALUES ('7e90ae90-566b-4aa4-abe6-5949bb6ddf6a', 'orders:view_reviews', 'Can view all order reviews', 'Orders', 'Có thể xem tất cả đánh giá của các đơn hàng');
INSERT INTO public.permissions VALUES ('eb6a4992-992d-4e3e-a592-14f6cd778a9a', 'reports:create', 'Create a service report', 'Reports', 'Tạo một báo cáo sai lệch');
INSERT INTO public.permissions VALUES ('f5f27112-1896-400e-815a-331f75aab56e', 'reports:resolve', 'Xử lý và giải quyết báo cáo', 'Reports', 'Xử lý và đóng một báo cáo sai lệch');
INSERT INTO public.permissions VALUES ('d5b086c2-5d9c-46a7-9813-26e38e421228', 'reports:view', 'Xem các báo cáo sai lệch', 'Reports', 'Xem danh sách các báo cáo sai lệch từ farmer');
INSERT INTO public.permissions VALUES ('5fb2c10c-c4f5-4991-a9b1-9a59e8cb63ef', 'work_session:cancel', 'Hủy một phiên làm việc đang hoạt động', 'Work Sessions', 'Hủy một phiên làm việc đang diễn ra');
INSERT INTO public.permissions VALUES ('ff4a7ad7-8b29-40f8-a02a-13fe0377f3b8', 'work_session:finish', 'Kết thúc một phiên làm việc', 'Work Sessions', 'Kết thúc một phiên làm việc và ghi nhận tiến độ');
INSERT INTO public.permissions VALUES ('cce2a951-3a7f-4022-8ddd-06646a2122b4', 'work_session:override', 'Can finish/cancel work sessions of other users', 'Work Sessions', 'Có thể kết thúc/hủy phiên làm việc của người khác');
INSERT INTO public.permissions VALUES ('93f487fd-8b17-4dd7-bffd-337dad26799d', 'work_session:start', 'Bắt đầu một phiên làm việc', 'Work Sessions', 'Bắt đầu một phiên làm việc mới cho một đơn hàng');


--
-- Data for Name: product_variant_attributes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.product_variant_attributes VALUES ('d0f34b02-af5b-49f6-9c9a-29eb642c334f', 'fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5');
INSERT INTO public.product_variant_attributes VALUES ('06884185-af8a-4a02-ac36-ebab58becb4f', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('6c9f15e1-cfd4-419c-84d1-41137946a7d1', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('91defb3b-1d3c-4dc2-99f2-afdc30065ac5', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('8e0d6cd0-709e-49f5-aff2-b5596b29a7cf', 'fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5');
INSERT INTO public.product_variant_attributes VALUES ('5f664629-5e3f-488a-94e2-02a21664fc60', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('6721a751-98c6-4300-93a0-5e2da038fcc9', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('cacb9062-27c9-4ec9-8d1e-10dee3fc3978', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('015759c6-fd45-4827-85b3-0b8a16d112c8', 'fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5');
INSERT INTO public.product_variant_attributes VALUES ('4ae6d1da-2dda-4092-ab73-4749424e4914', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('7163642d-896c-48e1-8cf6-d95025625d16', '526f5c1b-cd1b-43db-ba18-bf7aa52aa5e6');
INSERT INTO public.product_variant_attributes VALUES ('505e11df-7ee3-4d20-9f31-659ffb13d1eb', 'fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5');
INSERT INTO public.product_variant_attributes VALUES ('be79c704-2a69-43c1-8268-06fb6ff1569e', 'fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5');
INSERT INTO public.product_variant_attributes VALUES ('711a6b84-b6d2-492e-be62-2ae8db0bf795', 'fe8cf9e7-3843-4c5f-a2ef-dfaa514e89b5');


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.roles VALUES ('940747d3-9420-4b3d-ae97-171524915a44', 'accountant', 'Accountant');
INSERT INTO public.roles VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'admin', 'Administrator');
INSERT INTO public.roles VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'farmer', 'Farmer');
INSERT INTO public.roles VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'farmer_leader', 'Farmer Leader');
INSERT INTO public.roles VALUES ('73aad0ab-482e-4570-bdbc-3afd87d717d4', 'farmer_manager', 'Farmer Manager');
INSERT INTO public.roles VALUES ('bf1f1076-aa77-47b5-ba76-8b2eae1c6be7', 'leader', 'Leader');
INSERT INTO public.roles VALUES ('ed33248e-551d-447e-b4af-0da7d89702bf', 'manager', 'Manager');
INSERT INTO public.roles VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'mod', 'Moderator');
INSERT INTO public.roles VALUES ('22e71e67-058d-41af-99ec-f1e5d75b4447', 'trader_leader', 'Trader Leader');
INSERT INTO public.roles VALUES ('6be1c56b-d90d-4b5d-aa82-c107d223b4b6', 'trader_manager', 'Trader Manager');
INSERT INTO public.roles VALUES ('3e2b1e17-87bb-4ec6-b0f3-b2fc4481daf2', 'trader1', 'Trader1');
INSERT INTO public.roles VALUES ('d03016e7-ce8d-4808-80e9-6ed5aaa521b3', 'trader2', 'Trader2');
INSERT INTO public.roles VALUES ('e2b79619-2bbc-4f1a-b7b0-8ef47e19e34f', 'trial', 'Trial');


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '0707495e-ece2-4905-8046-a6e65353e2aa');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'd2c93eae-dcc1-4024-b9fc-1d22b0ca62e0');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '61c33853-ab38-439d-892e-1dbbe558d26b');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '744c5815-e4f6-4073-93c9-19b91447ae4b');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '7e90ae90-566b-4aa4-abe6-5949bb6ddf6a');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '98b8f11c-5350-4bac-baae-473424e8f27f');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'e0997ce9-f1f9-415d-ba88-9e315a85fa9c');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '827f35cf-67d5-4bcf-9477-bd7f9d82bbe6');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'a45d15b1-4cf3-4f47-ba7f-182fd1f72b8a');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'bfa14d6a-fe62-4664-b3b5-88eea8e2e049');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'd5b086c2-5d9c-46a7-9813-26e38e421228');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'cce2a951-3a7f-4022-8ddd-06646a2122b4');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'ff4a7ad7-8b29-40f8-a02a-13fe0377f3b8');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'f5f27112-1896-400e-815a-331f75aab56e');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', 'eb6a4992-992d-4e3e-a592-14f6cd778a9a');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '5fb2c10c-c4f5-4991-a9b1-9a59e8cb63ef');
INSERT INTO public.role_permissions VALUES ('057fc788-7788-442a-9c32-39cfdbec6547', '93f487fd-8b17-4dd7-bffd-337dad26799d');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'd2c93eae-dcc1-4024-b9fc-1d22b0ca62e0');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'a45d15b1-4cf3-4f47-ba7f-182fd1f72b8a');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', '5fb2c10c-c4f5-4991-a9b1-9a59e8cb63ef');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', '93f487fd-8b17-4dd7-bffd-337dad26799d');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'ff4a7ad7-8b29-40f8-a02a-13fe0377f3b8');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'cce2a951-3a7f-4022-8ddd-06646a2122b4');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'eb6a4992-992d-4e3e-a592-14f6cd778a9a');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', 'd5b086c2-5d9c-46a7-9813-26e38e421228');
INSERT INTO public.role_permissions VALUES ('f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', '7e90ae90-566b-4aa4-abe6-5949bb6ddf6a');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', '5fb2c10c-c4f5-4991-a9b1-9a59e8cb63ef');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', '93f487fd-8b17-4dd7-bffd-337dad26799d');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'ff4a7ad7-8b29-40f8-a02a-13fe0377f3b8');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'cce2a951-3a7f-4022-8ddd-06646a2122b4');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'a45d15b1-4cf3-4f47-ba7f-182fd1f72b8a');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', '98b8f11c-5350-4bac-baae-473424e8f27f');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'd2c93eae-dcc1-4024-b9fc-1d22b0ca62e0');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'd5b086c2-5d9c-46a7-9813-26e38e421228');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'f5f27112-1896-400e-815a-331f75aab56e');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'eb6a4992-992d-4e3e-a592-14f6cd778a9a');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', '7e90ae90-566b-4aa4-abe6-5949bb6ddf6a');
INSERT INTO public.role_permissions VALUES ('e591b8c7-70de-4563-9d72-d1a7218801b2', 'e0997ce9-f1f9-415d-ba88-9e315a85fa9c');
INSERT INTO public.role_permissions VALUES ('73aad0ab-482e-4570-bdbc-3afd87d717d4', '5fb2c10c-c4f5-4991-a9b1-9a59e8cb63ef');
INSERT INTO public.role_permissions VALUES ('73aad0ab-482e-4570-bdbc-3afd87d717d4', '93f487fd-8b17-4dd7-bffd-337dad26799d');
INSERT INTO public.role_permissions VALUES ('73aad0ab-482e-4570-bdbc-3afd87d717d4', 'ff4a7ad7-8b29-40f8-a02a-13fe0377f3b8');
INSERT INTO public.role_permissions VALUES ('73aad0ab-482e-4570-bdbc-3afd87d717d4', 'cce2a951-3a7f-4022-8ddd-06646a2122b4');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '0707495e-ece2-4905-8046-a6e65353e2aa');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '827f35cf-67d5-4bcf-9477-bd7f9d82bbe6');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '61c33853-ab38-439d-892e-1dbbe558d26b');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '744c5815-e4f6-4073-93c9-19b91447ae4b');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'd2c93eae-dcc1-4024-b9fc-1d22b0ca62e0');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '98b8f11c-5350-4bac-baae-473424e8f27f');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'e0997ce9-f1f9-415d-ba88-9e315a85fa9c');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '7e90ae90-566b-4aa4-abe6-5949bb6ddf6a');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'a45d15b1-4cf3-4f47-ba7f-182fd1f72b8a');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'bfa14d6a-fe62-4664-b3b5-88eea8e2e049');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'd5b086c2-5d9c-46a7-9813-26e38e421228');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'cce2a951-3a7f-4022-8ddd-06646a2122b4');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'ff4a7ad7-8b29-40f8-a02a-13fe0377f3b8');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'f5f27112-1896-400e-815a-331f75aab56e');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', 'eb6a4992-992d-4e3e-a592-14f6cd778a9a');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '5fb2c10c-c4f5-4991-a9b1-9a59e8cb63ef');
INSERT INTO public.role_permissions VALUES ('c52bfc3b-d628-4576-b68a-1a7ca7c1c994', '93f487fd-8b17-4dd7-bffd-337dad26799d');


--
-- Data for Name: service_reports; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.service_reports VALUES ('3c409300-4e18-4f17-9f57-cce5199f2251', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', 'e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 01:17:55.026034+00', 'level paragon 1-300', '{}', NULL, NULL, 'resolved', '2025-09-22 01:19:51.462864+00', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'oke');
INSERT INTO public.service_reports VALUES ('eeb08e9a-b19e-4dbd-a915-f356307810fb', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', 'b1e0e3cc-adbf-4949-9992-84b0deccb870', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:01:17.214443+00', 'thiếu mats do master working tạch', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/cancellation/1758517276541_0qww2mt5ox8b.png}', NULL, NULL, 'resolved', '2025-09-22 05:02:16.133098+00', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'đã tăng lên 100k obducites');
INSERT INTO public.service_reports VALUES ('0b944fe2-7480-462f-b93a-c3e89963560b', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', 'b1e0e3cc-adbf-4949-9992-84b0deccb870', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:02:39.223789+00', 'sửa sai', '{}', NULL, NULL, 'resolved', '2025-09-22 05:03:11.249576+00', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'check lai');
INSERT INTO public.service_reports VALUES ('c6c56bf8-cde0-497e-b93b-e0cae8945212', '7b637335-aa61-429b-97be-092c438427ee', '0d01aae9-382e-42fc-aa39-754adfd5f28c', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:18:30.962863+00', 'farmer 1 Bảo chạy mới đến 29 nhưng báo là 30', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/cancellation/1758554310097_idnyb23i8j.png}', NULL, NULL, 'resolved', '2025-09-22 15:19:42.676616+00', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'đã giải quyết, bảo chú y hơn lần sau');
INSERT INTO public.service_reports VALUES ('a0dd769a-cf47-4c88-9dd3-5021463fd00a', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6', '95af0801-eabc-4d0a-a90d-c26deed08467', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:20:26.378981+00', 'level 29 k phải 30', '{https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/cancellation/1758558025313_8b4q3xz317d.png}', NULL, NULL, 'resolved', '2025-09-22 16:21:32.697945+00', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'đã fix');


--
-- Data for Name: user_role_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.user_role_assignments VALUES ('a25f32bb-ec39-456c-93c8-98af65c69db0', '8710590d-efde-4c63-99de-aba2014fe944', '057fc788-7788-442a-9c32-39cfdbec6547', NULL, NULL);
INSERT INTO public.user_role_assignments VALUES ('2c3a5891-0f42-49b8-a3ba-ea4c55691759', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '057fc788-7788-442a-9c32-39cfdbec6547', NULL, NULL);
INSERT INTO public.user_role_assignments VALUES ('3dcde50e-67f6-4c68-bc60-2a24b84f9dd3', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc', '0931ef6f-1848-4a90-8a72-1497bbd318a7', '0e6e5602-8512-4f2c-bb4e-d53c718b68ab');


--
-- Data for Name: work_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.work_sessions VALUES ('3106806e-4216-4301-92a6-cc88ee02261e', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '8710590d-efde-4c63-99de-aba2014fe944', '2025-09-22 04:26:41.449468+00', '2025-09-22 04:31:05.53158+00', '', NULL, '[{"item_id": "050dca03-cc40-4c9d-bb43-027304f100a7", "start_exp": 0, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b8da33c9-d361-4440-8046-1ee44481319c/050dca03-cc40-4c9d-bb43-027304f100a7/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('d4eee6b3-5b97-4098-83f9-85a9fc1acec5', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '8710590d-efde-4c63-99de-aba2014fe944', '2025-09-22 04:45:35.773268+00', '2025-09-22 04:47:07.290901+00', '', NULL, '[{"item_id": "050dca03-cc40-4c9d-bb43-027304f100a7", "start_exp": 0, "start_value": 10, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/3106806e-4216-4301-92a6-cc88ee02261e/050dca03-cc40-4c9d-bb43-027304f100a7/end.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('b4ec41c7-c060-4d5d-a16d-31cda9c04fb3', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:48:55.170475+00', '2025-09-22 04:49:20.251405+00', '', NULL, '[{"item_id": "e47d65bd-bbcf-4095-aeb6-017da7e7e9c0", "start_exp": 0, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/9c7858dc-50b4-4b17-b3ad-ecdd11f6f0c7/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('01d6badc-70db-4a42-8f8d-5e7cf311aa36', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:49:40.074863+00', '2025-09-22 04:49:58.073216+00', '', NULL, '[{"item_id": "e47d65bd-bbcf-4095-aeb6-017da7e7e9c0", "start_exp": 50, "start_value": 200, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b4ec41c7-c060-4d5d-a16d-31cda9c04fb3/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/end.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:52:30.271165+00', '2025-09-22 04:56:51.248375+00', '', NULL, '[{"item_id": "be5a5e91-6b88-4f59-b61a-fb260b0d48a3", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/be5a5e91-6b88-4f59-b61a-fb260b0d48a3/start.png"}, {"item_id": "756f4a4d-91e9-4b98-a198-a2974617cadd", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/756f4a4d-91e9-4b98-a198-a2974617cadd/start.png"}, {"item_id": "4c0b6f8e-c878-445c-ae75-ce4483c0ec98", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/4c0b6f8e-c878-445c-ae75-ce4483c0ec98/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:58:03.103572+00', '2025-09-22 04:58:43.39879+00', '', NULL, '[{"item_id": "e01e7210-8053-4f54-830f-dc51c634154c", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/76adf87f-5ec6-4031-a4e6-8545360926cf/e01e7210-8053-4f54-830f-dc51c634154c/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('8df4b0c5-8f4b-4e63-9399-41d7acf998fb', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:59:05.474343+00', '2025-09-22 04:59:48.892515+00', '', NULL, '[{"item_id": "e01e7210-8053-4f54-830f-dc51c634154c", "start_exp": null, "start_value": 15000, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70/e01e7210-8053-4f54-830f-dc51c634154c/end.png"}, {"item_id": "b1e0e3cc-adbf-4949-9992-84b0deccb870", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/950cf104-7cbb-4586-9048-0265e422a677/b1e0e3cc-adbf-4949-9992-84b0deccb870/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('7d6a7dd8-1d6c-4078-b35f-5576b77fa594', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:07:22.231546+00', '2025-09-22 05:07:54.143963+00', '', NULL, '[{"item_id": "50a08ed9-e6a3-484c-8f7b-ea068255bbee", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/fd3d2161-5516-459c-bedb-1851d1dfc389/50a08ed9-e6a3-484c-8f7b-ea068255bbee/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('4f90d2c5-35f8-4d4f-af93-578b4f7aafca', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:08:15.852439+00', '2025-09-22 05:08:55.79047+00', '', NULL, '[{"item_id": "b1e0e3cc-adbf-4949-9992-84b0deccb870", "start_exp": null, "start_value": 2500000, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('07a55ba8-bb1f-48f3-b8a8-82d4059d140b', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:09:06.740461+00', '2025-09-22 05:09:21.663988+00', '', NULL, '[{"item_id": "b1e0e3cc-adbf-4949-9992-84b0deccb870", "start_exp": null, "start_value": 2500000, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('8d790d31-9f37-43d9-baae-15a8ea9f4b3f', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:09:36.647306+00', '2025-09-22 05:09:43.745853+00', '', NULL, '[{"item_id": "da219c16-9450-4eb9-b456-6257866ea0f4", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d33efa7e-216b-40d1-96ab-2084a642c116/da219c16-9450-4eb9-b456-6257866ea0f4/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('1e27bcce-a6f8-4336-ad81-814581d91ece', '99845878-ad7d-4520-a213-cfcfbca9b2e6', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 14:58:50.447711+00', NULL, '', NULL, '[{"item_id": "774a71a6-c241-4de3-b2e2-ec9d71dc93f6", "start_exp": 0, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/99845878-ad7d-4520-a213-cfcfbca9b2e6/a5adadbb-e037-492c-b9ff-4dd88e54db1a/774a71a6-c241-4de3-b2e2-ec9d71dc93f6/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('3bfc4bd5-df11-44b1-b076-0839a85ef9d7', '0f442910-726b-4f8a-9419-c3480a842990', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 14:59:25.885839+00', NULL, '', NULL, '[{"item_id": "3afe836b-e565-4953-93d2-661d0878bbb2", "start_exp": 0, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/0f442910-726b-4f8a-9419-c3480a842990/5ec3f70c-fb38-4d3d-8182-f2aa3ab2e6ff/3afe836b-e565-4953-93d2-661d0878bbb2/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('a1578e42-1295-4110-833a-ebbe7da74534', '7b637335-aa61-429b-97be-092c438427ee', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:16:07.687384+00', '2025-09-22 15:16:52.489126+00', '', NULL, '[{"item_id": "0d01aae9-382e-42fc-aa39-754adfd5f28c", "start_exp": 10, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/8f4f965b-d8f1-492c-bde2-078fcb0143e8/0d01aae9-382e-42fc-aa39-754adfd5f28c/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('dc3826a9-be41-46a8-942c-d56779e18475', '7b637335-aa61-429b-97be-092c438427ee', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:20:09.202306+00', '2025-09-22 15:20:26.550914+00', '', NULL, '[{"item_id": "0d01aae9-382e-42fc-aa39-754adfd5f28c", "start_exp": 40, "start_value": 30, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/a1578e42-1295-4110-833a-ebbe7da74534/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png"}]', '00:03:16.71318');
INSERT INTO public.work_sessions VALUES ('677dbd59-b91a-4de9-9504-d00d7d429b53', '7b637335-aa61-429b-97be-092c438427ee', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:20:57.129209+00', '2025-09-22 15:21:04.586921+00', '', NULL, '[{"item_id": "0d01aae9-382e-42fc-aa39-754adfd5f28c", "start_exp": 0, "start_value": 60, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/dc3826a9-be41-46a8-942c-d56779e18475/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png"}]', '00:00:30.578295');
INSERT INTO public.work_sessions VALUES ('24c58bad-f4c7-4aa4-abf4-e23854867c34', '7b637335-aa61-429b-97be-092c438427ee', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:21:30.597528+00', '2025-09-22 15:22:09.656321+00', '', NULL, '[{"item_id": "47bcf011-8161-430f-966e-f6b6f2a7c92a", "start_exp": 0, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/e86c5a8c-ae52-4503-81a4-2d3b6024e303/47bcf011-8161-430f-966e-f6b6f2a7c92a/start.png"}]', '00:00:26.010607');
INSERT INTO public.work_sessions VALUES ('01a2becf-2c47-4508-b738-aa03392c73c6', '7b637335-aa61-429b-97be-092c438427ee', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:23:13.693729+00', '2025-09-22 15:23:31.922752+00', '', NULL, '[{"item_id": "e84b5499-2d23-48b3-9d18-347630e09cc1", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/245337b1-6e94-4932-a4f3-a2754d99dcb3/e84b5499-2d23-48b3-9d18-347630e09cc1/start.png"}]', '00:01:04.037408');
INSERT INTO public.work_sessions VALUES ('eaa3d558-37dc-49a5-972e-e550975fcb9a', '88162217-4bce-4014-aec7-466508a9ec43', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:40:27.7157+00', '2025-09-22 15:40:50.17682+00', '', NULL, '[{"item_id": "47c23563-689a-4fbd-b3a4-134204fb4f34", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/88162217-4bce-4014-aec7-466508a9ec43/7bc93758-4400-4996-905d-7eabd8dbe6f2/47c23563-689a-4fbd-b3a4-134204fb4f34/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('f674a516-1e74-4caa-8bb8-bbb36f4fd8d2', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:43:46.074041+00', '2025-09-22 15:44:25.642568+00', '', NULL, '[{"item_id": "8fabd6a2-f160-4012-8712-d7184c305648", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/8fabd6a2-f160-4012-8712-d7184c305648/start.png"}, {"item_id": "6f8542b1-7c2a-47be-922f-d8059d9d8a9c", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/start.png"}, {"item_id": "ffcb84f5-c839-4efe-be8c-40f4888ca3b0", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('d15a29ac-bc79-4d55-829d-37119aa66129', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:44:43.084383+00', '2025-09-22 15:45:01.992219+00', '', NULL, '[{"item_id": "8fabd6a2-f160-4012-8712-d7184c305648", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/6b62abff-c3b3-4000-a64f-8d390953812c/8fabd6a2-f160-4012-8712-d7184c305648/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('86087992-d92f-48b4-aa56-38ca5b84a27c', '90e39f2e-280e-41e4-8237-48f57832d653', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:46:39.001465+00', '2025-09-22 15:48:22.603667+00', '', 'farm lố', '[{"item_id": "6bcee3a9-3d3d-4de5-8c41-f5058dfaa126", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/aaed1730-ff56-4ccb-a924-66f78ad71267/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('7b9b7c9d-681b-4817-883b-683637d8e3f8', '90e39f2e-280e-41e4-8237-48f57832d653', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:48:51.010658+00', '2025-09-22 15:48:57.785928+00', '', 'farm lố', '[{"item_id": "ba293e3e-ce8d-472b-b27e-ea4d96616f3b", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/8d9d474b-c5f6-4aeb-8fec-6686ea3f4cad/ba293e3e-ce8d-472b-b27e-ea4d96616f3b/start.png"}, {"item_id": "6bcee3a9-3d3d-4de5-8c41-f5058dfaa126", "start_exp": null, "start_value": 16000, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/86087992-d92f-48b4-aa56-38ca5b84a27c/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126/end.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('c6574b07-2078-4517-8044-94890328c4d2', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:55:56.529505+00', '2025-09-22 15:56:22.830476+00', '', NULL, '[{"item_id": "cc5e09ed-8248-4d85-ad83-f0a963b124eb", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/cc5e09ed-8248-4d85-ad83-f0a963b124eb/start.png"}, {"item_id": "499ffbcf-53c1-48cc-9d0d-4332be499dc1", "start_exp": null, "start_value": 0, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/499ffbcf-53c1-48cc-9d0d-4332be499dc1/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('ad9de662-2681-42d3-abfc-18a01dbfbf1e', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:05:44.493673+00', '2025-09-22 16:06:00.56211+00', '', NULL, '[{"item_id": "6f8542b1-7c2a-47be-922f-d8059d9d8a9c", "start_exp": null, "start_value": 15000, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/end.png"}, {"item_id": "ffcb84f5-c839-4efe-be8c-40f4888ca3b0", "start_exp": null, "start_value": 250000, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/end.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('33ae8e85-062b-4bd7-84e2-39f3f0635aae', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:19:52.482644+00', '2025-09-22 16:20:02.632687+00', '', NULL, '[{"item_id": "95af0801-eabc-4d0a-a90d-c26deed08467", "start_exp": 0, "start_value": 1, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/f38ed7dc-4d0a-4a2b-bf4a-e1eecd0371d7/95af0801-eabc-4d0a-a90d-c26deed08467/start.png"}]', NULL);
INSERT INTO public.work_sessions VALUES ('be400f88-15bd-4cb6-a691-c20795cf33bd', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:20:33.675627+00', NULL, '', NULL, '[{"item_id": "95af0801-eabc-4d0a-a90d-c26deed08467", "start_exp": 0, "start_value": 28, "start_proof_url": "https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/33ae8e85-062b-4bd7-84e2-39f3f0635aae/95af0801-eabc-4d0a-a90d-c26deed08467/end.png"}]', NULL);


--
-- Data for Name: work_session_outputs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.work_session_outputs VALUES ('22d5f52e-8aec-47bd-85c5-0b0d77d1d23f', '3106806e-4216-4301-92a6-cc88ee02261e', '050dca03-cc40-4c9d-bb43-027304f100a7', 9, NULL, 1, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b8da33c9-d361-4440-8046-1ee44481319c/050dca03-cc40-4c9d-bb43-027304f100a7/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/3106806e-4216-4301-92a6-cc88ee02261e/050dca03-cc40-4c9d-bb43-027304f100a7/end.png', '{"exp_percent": 0}');
INSERT INTO public.work_session_outputs VALUES ('1e0e8277-ff2b-4155-878b-50fc4fdf5788', 'd4eee6b3-5b97-4098-83f9-85a9fc1acec5', '050dca03-cc40-4c9d-bb43-027304f100a7', 50, NULL, 10, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/3106806e-4216-4301-92a6-cc88ee02261e/050dca03-cc40-4c9d-bb43-027304f100a7/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d4eee6b3-5b97-4098-83f9-85a9fc1acec5/050dca03-cc40-4c9d-bb43-027304f100a7/end.png', '{"exp_percent": 0}');
INSERT INTO public.work_session_outputs VALUES ('d792192e-87af-4249-8111-2eb90067a8ae', 'b4ec41c7-c060-4d5d-a16d-31cda9c04fb3', 'e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', 199, NULL, 1, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/9c7858dc-50b4-4b17-b3ad-ecdd11f6f0c7/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b4ec41c7-c060-4d5d-a16d-31cda9c04fb3/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/end.png', '{"exp_percent": 50}');
INSERT INTO public.work_session_outputs VALUES ('19e1ddd5-f930-4fbe-89f0-282479b6e7cf', '01d6badc-70db-4a42-8f8d-5e7cf311aa36', 'e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', 100, NULL, 200, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b4ec41c7-c060-4d5d-a16d-31cda9c04fb3/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/01d6badc-70db-4a42-8f8d-5e7cf311aa36/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/end.png', '{"exp_percent": 0}');
INSERT INTO public.work_session_outputs VALUES ('172358b3-7bbc-495b-8146-66600ca211ce', '6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', 'be5a5e91-6b88-4f59-b61a-fb260b0d48a3', 1, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/be5a5e91-6b88-4f59-b61a-fb260b0d48a3/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/be5a5e91-6b88-4f59-b61a-fb260b0d48a3/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('e3804c66-b1ec-4a55-a6ca-7e4f572be942', '6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', '756f4a4d-91e9-4b98-a198-a2974617cadd', 1, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/756f4a4d-91e9-4b98-a198-a2974617cadd/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/756f4a4d-91e9-4b98-a198-a2974617cadd/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('3b403a01-1af3-412f-99cd-005faac14b2c', '6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', '4c0b6f8e-c878-445c-ae75-ce4483c0ec98', 1, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/4c0b6f8e-c878-445c-ae75-ce4483c0ec98/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/4c0b6f8e-c878-445c-ae75-ce4483c0ec98/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('b39775c2-32b2-4429-832d-f589c82aff0b', '6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', 'be5a5e91-6b88-4f59-b61a-fb260b0d48a3', 200, NULL, 0, NULL, NULL, '{"label": "BELIAL_LORD_OF_LIES"}');
INSERT INTO public.work_session_outputs VALUES ('6b5898ee-142a-4e21-bcdd-849c60ddc8f2', '6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', '756f4a4d-91e9-4b98-a198-a2974617cadd', 200, NULL, 0, NULL, NULL, '{"label": "BELIAL_LORD_OF_LIES"}');
INSERT INTO public.work_session_outputs VALUES ('31fe31d2-8bc8-4bba-80a5-0a2e355ca41f', '6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', '4c0b6f8e-c878-445c-ae75-ce4483c0ec98', 200, NULL, 0, NULL, NULL, '{"label": "BELIAL_LORD_OF_LIES"}');
INSERT INTO public.work_session_outputs VALUES ('cd24a04d-b8c0-45f8-b67f-55a465fbe774', 'bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70', 'e01e7210-8053-4f54-830f-dc51c634154c', 15000, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/76adf87f-5ec6-4031-a4e6-8545360926cf/e01e7210-8053-4f54-830f-dc51c634154c/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70/e01e7210-8053-4f54-830f-dc51c634154c/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('90c95e56-213d-4129-9453-3979dd135441', '8df4b0c5-8f4b-4e63-9399-41d7acf998fb', 'b1e0e3cc-adbf-4949-9992-84b0deccb870', 2500000, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/950cf104-7cbb-4586-9048-0265e422a677/b1e0e3cc-adbf-4949-9992-84b0deccb870/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('937054a2-484e-4e1f-9628-449d44385d46', '7d6a7dd8-1d6c-4078-b35f-5576b77fa594', '50a08ed9-e6a3-484c-8f7b-ea068255bbee', 10, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/fd3d2161-5516-459c-bedb-1851d1dfc389/50a08ed9-e6a3-484c-8f7b-ea068255bbee/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/7d6a7dd8-1d6c-4078-b35f-5576b77fa594/50a08ed9-e6a3-484c-8f7b-ea068255bbee/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('8caf120d-7d63-4f98-9de7-b82c0322db81', '07a55ba8-bb1f-48f3-b8a8-82d4059d140b', 'b1e0e3cc-adbf-4949-9992-84b0deccb870', 1000000, NULL, 2500000, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/07a55ba8-bb1f-48f3-b8a8-82d4059d140b/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('2c23d9b2-c300-433b-8368-b4e6385dfdb8', '8d790d31-9f37-43d9-baae-15a8ea9f4b3f', 'da219c16-9450-4eb9-b456-6257866ea0f4', 1, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d33efa7e-216b-40d1-96ab-2084a642c116/da219c16-9450-4eb9-b456-6257866ea0f4/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8d790d31-9f37-43d9-baae-15a8ea9f4b3f/da219c16-9450-4eb9-b456-6257866ea0f4/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('d4f60b74-9c98-4ce8-a258-81bc9a4c1330', 'a1578e42-1295-4110-833a-ebbe7da74534', '0d01aae9-382e-42fc-aa39-754adfd5f28c', 29, NULL, 1, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/8f4f965b-d8f1-492c-bde2-078fcb0143e8/0d01aae9-382e-42fc-aa39-754adfd5f28c/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/a1578e42-1295-4110-833a-ebbe7da74534/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', '{"exp_percent": 40}');
INSERT INTO public.work_session_outputs VALUES ('01313b55-9ce7-4714-a200-85e82b2c5b0b', 'dc3826a9-be41-46a8-942c-d56779e18475', '0d01aae9-382e-42fc-aa39-754adfd5f28c', 30, NULL, 30, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/a1578e42-1295-4110-833a-ebbe7da74534/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/dc3826a9-be41-46a8-942c-d56779e18475/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', '{"exp_percent": 0}');
INSERT INTO public.work_session_outputs VALUES ('e9b9b271-880a-430f-b978-a0fc0478351f', '677dbd59-b91a-4de9-9504-d00d7d429b53', '0d01aae9-382e-42fc-aa39-754adfd5f28c', 1, NULL, 60, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/dc3826a9-be41-46a8-942c-d56779e18475/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/677dbd59-b91a-4de9-9504-d00d7d429b53/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', '{"exp_percent": 0}');
INSERT INTO public.work_session_outputs VALUES ('82f49881-ccdb-4010-8214-fcf0911c7a19', '24c58bad-f4c7-4aa4-abf4-e23854867c34', '47bcf011-8161-430f-966e-f6b6f2a7c92a', 149, NULL, 1, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/e86c5a8c-ae52-4503-81a4-2d3b6024e303/47bcf011-8161-430f-966e-f6b6f2a7c92a/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/24c58bad-f4c7-4aa4-abf4-e23854867c34/47bcf011-8161-430f-966e-f6b6f2a7c92a/end.png', '{"exp_percent": 0}');
INSERT INTO public.work_session_outputs VALUES ('ecaf48f6-104e-41c2-8d89-1d0a6a16d31c', '01a2becf-2c47-4508-b738-aa03392c73c6', 'e84b5499-2d23-48b3-9d18-347630e09cc1', 200, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/245337b1-6e94-4932-a4f3-a2754d99dcb3/e84b5499-2d23-48b3-9d18-347630e09cc1/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/7b637335-aa61-429b-97be-092c438427ee/01a2becf-2c47-4508-b738-aa03392c73c6/e84b5499-2d23-48b3-9d18-347630e09cc1/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('4ca74a6f-794b-4da0-aa71-bde2de23d56d', 'eaa3d558-37dc-49a5-972e-e550975fcb9a', '47c23563-689a-4fbd-b3a4-134204fb4f34', 10, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/88162217-4bce-4014-aec7-466508a9ec43/7bc93758-4400-4996-905d-7eabd8dbe6f2/47c23563-689a-4fbd-b3a4-134204fb4f34/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/88162217-4bce-4014-aec7-466508a9ec43/eaa3d558-37dc-49a5-972e-e550975fcb9a/47c23563-689a-4fbd-b3a4-134204fb4f34/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('f9e6966c-e5ca-4441-bca1-0ac0663acc4c', 'f674a516-1e74-4caa-8bb8-bbb36f4fd8d2', '6f8542b1-7c2a-47be-922f-d8059d9d8a9c', 15000, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('b19295a8-eb41-4373-9fdd-debf5e5a7278', 'f674a516-1e74-4caa-8bb8-bbb36f4fd8d2', 'ffcb84f5-c839-4efe-be8c-40f4888ca3b0', 250000, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('0fd9d1cb-8d14-4c38-a195-137c58d1334a', 'd15a29ac-bc79-4d55-829d-37119aa66129', '8fabd6a2-f160-4012-8712-d7184c305648', 10, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/6b62abff-c3b3-4000-a64f-8d390953812c/8fabd6a2-f160-4012-8712-d7184c305648/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/d15a29ac-bc79-4d55-829d-37119aa66129/8fabd6a2-f160-4012-8712-d7184c305648/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('8d70d474-7359-456c-adb5-12ae15792f4e', '86087992-d92f-48b4-aa56-38ca5b84a27c', '6bcee3a9-3d3d-4de5-8c41-f5058dfaa126', 16000, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/aaed1730-ff56-4ccb-a924-66f78ad71267/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/86087992-d92f-48b4-aa56-38ca5b84a27c/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('e2cba239-4a19-499b-a44c-eda3b6393b3f', '7b9b7c9d-681b-4817-883b-683637d8e3f8', 'ba293e3e-ce8d-472b-b27e-ea4d96616f3b', 10, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/8d9d474b-c5f6-4aeb-8fec-6686ea3f4cad/ba293e3e-ce8d-472b-b27e-ea4d96616f3b/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/90e39f2e-280e-41e4-8237-48f57832d653/7b9b7c9d-681b-4817-883b-683637d8e3f8/ba293e3e-ce8d-472b-b27e-ea4d96616f3b/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('0c93c0ed-75d1-4ece-92f4-e8a5fd1c0cae', 'c6574b07-2078-4517-8044-94890328c4d2', 'cc5e09ed-8248-4d85-ad83-f0a963b124eb', 1, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/cc5e09ed-8248-4d85-ad83-f0a963b124eb/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2/cc5e09ed-8248-4d85-ad83-f0a963b124eb/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('344ef40b-deb5-4343-88e5-e7082d5ae2ea', 'c6574b07-2078-4517-8044-94890328c4d2', '499ffbcf-53c1-48cc-9d0d-4332be499dc1', 1, NULL, 0, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/499ffbcf-53c1-48cc-9d0d-4332be499dc1/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2/499ffbcf-53c1-48cc-9d0d-4332be499dc1/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('1a7b97af-8d1b-42e6-a3dd-832a737d1588', 'c6574b07-2078-4517-8044-94890328c4d2', 'cc5e09ed-8248-4d85-ad83-f0a963b124eb', 200, NULL, 0, NULL, NULL, '{"label": "BELIAL_LORD_OF_LIES"}');
INSERT INTO public.work_session_outputs VALUES ('569e52d0-41ac-48bb-874e-72d6c01225f4', 'c6574b07-2078-4517-8044-94890328c4d2', '499ffbcf-53c1-48cc-9d0d-4332be499dc1', 200, NULL, 0, NULL, NULL, '{"label": "BELIAL_LORD_OF_LIES"}');
INSERT INTO public.work_session_outputs VALUES ('0cc5a248-24cd-4a11-981d-90807635dfe4', 'ad9de662-2681-42d3-abfc-18a01dbfbf1e', '6f8542b1-7c2a-47be-922f-d8059d9d8a9c', 5000, NULL, 15000, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('488dc57a-5e37-4920-9733-37d1741bc01c', 'ad9de662-2681-42d3-abfc-18a01dbfbf1e', 'ffcb84f5-c839-4efe-be8c-40f4888ca3b0', 50000, NULL, 250000, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/end.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/end.png', NULL);
INSERT INTO public.work_session_outputs VALUES ('8e7b223b-3533-4166-bd3d-b225aab9646e', '33ae8e85-062b-4bd7-84e2-39f3f0635aae', '95af0801-eabc-4d0a-a90d-c26deed08467', 29, NULL, 1, 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/f38ed7dc-4d0a-4a2b-bf4a-e1eecd0371d7/95af0801-eabc-4d0a-a90d-c26deed08467/start.png', 'https://susuoambmzdmcygovkea.supabase.co/storage/v1/object/public/work-proofs/2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/33ae8e85-062b-4bd7-84e2-39f3f0635aae/95af0801-eabc-4d0a-a90d-c26deed08467/end.png', '{"exp_percent": 0}');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

INSERT INTO storage.buckets VALUES ('work-proofs', 'work-proofs', NULL, '2025-09-22 00:20:01.431101+00', '2025-09-22 00:20:01.431101+00', true, false, 52428800, NULL, NULL, 'STANDARD');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

INSERT INTO storage.migrations VALUES (0, 'create-migrations-table', 'e18db593bcde2aca2a408c4d1100f6abba2195df', '2025-09-21 17:18:35.793982');
INSERT INTO storage.migrations VALUES (1, 'initialmigration', '6ab16121fbaa08bbd11b712d05f358f9b555d777', '2025-09-21 17:18:35.808105');
INSERT INTO storage.migrations VALUES (2, 'storage-schema', '5c7968fd083fcea04050c1b7f6253c9771b99011', '2025-09-21 17:18:35.812745');
INSERT INTO storage.migrations VALUES (3, 'pathtoken-column', '2cb1b0004b817b29d5b0a971af16bafeede4b70d', '2025-09-21 17:18:35.865177');
INSERT INTO storage.migrations VALUES (4, 'add-migrations-rls', '427c5b63fe1c5937495d9c635c263ee7a5905058', '2025-09-21 17:18:35.974036');
INSERT INTO storage.migrations VALUES (5, 'add-size-functions', '79e081a1455b63666c1294a440f8ad4b1e6a7f84', '2025-09-21 17:18:35.977439');
INSERT INTO storage.migrations VALUES (6, 'change-column-name-in-get-size', 'f93f62afdf6613ee5e7e815b30d02dc990201044', '2025-09-21 17:18:35.981305');
INSERT INTO storage.migrations VALUES (7, 'add-rls-to-buckets', 'e7e7f86adbc51049f341dfe8d30256c1abca17aa', '2025-09-21 17:18:35.984886');
INSERT INTO storage.migrations VALUES (8, 'add-public-to-buckets', 'fd670db39ed65f9d08b01db09d6202503ca2bab3', '2025-09-21 17:18:35.988214');
INSERT INTO storage.migrations VALUES (9, 'fix-search-function', '3a0af29f42e35a4d101c259ed955b67e1bee6825', '2025-09-21 17:18:35.99123');
INSERT INTO storage.migrations VALUES (10, 'search-files-search-function', '68dc14822daad0ffac3746a502234f486182ef6e', '2025-09-21 17:18:35.994011');
INSERT INTO storage.migrations VALUES (11, 'add-trigger-to-auto-update-updated_at-column', '7425bdb14366d1739fa8a18c83100636d74dcaa2', '2025-09-21 17:18:35.998547');
INSERT INTO storage.migrations VALUES (12, 'add-automatic-avif-detection-flag', '8e92e1266eb29518b6a4c5313ab8f29dd0d08df9', '2025-09-21 17:18:36.0208');
INSERT INTO storage.migrations VALUES (13, 'add-bucket-custom-limits', 'cce962054138135cd9a8c4bcd531598684b25e7d', '2025-09-21 17:18:36.024502');
INSERT INTO storage.migrations VALUES (14, 'use-bytes-for-max-size', '941c41b346f9802b411f06f30e972ad4744dad27', '2025-09-21 17:18:36.027433');
INSERT INTO storage.migrations VALUES (15, 'add-can-insert-object-function', '934146bc38ead475f4ef4b555c524ee5d66799e5', '2025-09-21 17:18:36.060397');
INSERT INTO storage.migrations VALUES (16, 'add-version', '76debf38d3fd07dcfc747ca49096457d95b1221b', '2025-09-21 17:18:36.06329');
INSERT INTO storage.migrations VALUES (17, 'drop-owner-foreign-key', 'f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101', '2025-09-21 17:18:36.065772');
INSERT INTO storage.migrations VALUES (18, 'add_owner_id_column_deprecate_owner', 'e7a511b379110b08e2f214be852c35414749fe66', '2025-09-21 17:18:36.073587');
INSERT INTO storage.migrations VALUES (19, 'alter-default-value-objects-id', '02e5e22a78626187e00d173dc45f58fa66a4f043', '2025-09-21 17:18:36.078595');
INSERT INTO storage.migrations VALUES (20, 'list-objects-with-delimiter', 'cd694ae708e51ba82bf012bba00caf4f3b6393b7', '2025-09-21 17:18:36.082014');
INSERT INTO storage.migrations VALUES (21, 's3-multipart-uploads', '8c804d4a566c40cd1e4cc5b3725a664a9303657f', '2025-09-21 17:18:36.087705');
INSERT INTO storage.migrations VALUES (22, 's3-multipart-uploads-big-ints', '9737dc258d2397953c9953d9b86920b8be0cdb73', '2025-09-21 17:18:36.104736');
INSERT INTO storage.migrations VALUES (23, 'optimize-search-function', '9d7e604cddc4b56a5422dc68c9313f4a1b6f132c', '2025-09-21 17:18:36.147555');
INSERT INTO storage.migrations VALUES (24, 'operation-function', '8312e37c2bf9e76bbe841aa5fda889206d2bf8aa', '2025-09-21 17:18:36.150598');
INSERT INTO storage.migrations VALUES (25, 'custom-metadata', 'd974c6057c3db1c1f847afa0e291e6165693b990', '2025-09-21 17:18:36.153908');
INSERT INTO storage.migrations VALUES (26, 'objects-prefixes', 'ef3f7871121cdc47a65308e6702519e853422ae2', '2025-09-22 00:19:03.923672');
INSERT INTO storage.migrations VALUES (27, 'search-v2', '33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2', '2025-09-22 00:19:03.994997');
INSERT INTO storage.migrations VALUES (28, 'object-bucket-name-sorting', 'ba85ec41b62c6a30a3f136788227ee47f311c436', '2025-09-22 00:19:04.006358');
INSERT INTO storage.migrations VALUES (29, 'create-prefixes', 'a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b', '2025-09-22 00:19:04.012059');
INSERT INTO storage.migrations VALUES (30, 'update-object-levels', '6c6f6cc9430d570f26284a24cf7b210599032db7', '2025-09-22 00:19:04.018528');
INSERT INTO storage.migrations VALUES (31, 'objects-level-index', '33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8', '2025-09-22 00:19:04.025918');
INSERT INTO storage.migrations VALUES (32, 'backward-compatible-index-on-objects', '2d51eeb437a96868b36fcdfb1ddefdf13bef1647', '2025-09-22 00:19:04.033834');
INSERT INTO storage.migrations VALUES (33, 'backward-compatible-index-on-prefixes', 'fe473390e1b8c407434c0e470655945b110507bf', '2025-09-22 00:19:04.041813');
INSERT INTO storage.migrations VALUES (34, 'optimize-search-function-v1', '82b0e469a00e8ebce495e29bfa70a0797f7ebd2c', '2025-09-22 00:19:04.043985');
INSERT INTO storage.migrations VALUES (35, 'add-insert-trigger-prefixes', '63bb9fd05deb3dc5e9fa66c83e82b152f0caf589', '2025-09-22 00:19:04.055196');
INSERT INTO storage.migrations VALUES (36, 'optimise-existing-functions', '81cf92eb0c36612865a18016a38496c530443899', '2025-09-22 00:19:04.060224');
INSERT INTO storage.migrations VALUES (37, 'add-bucket-name-length-trigger', '3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1', '2025-09-22 00:19:04.075421');
INSERT INTO storage.migrations VALUES (38, 'iceberg-catalog-flag-on-buckets', '19a8bd89d5dfa69af7f222a46c726b7c41e462c5', '2025-09-22 00:19:04.081154');


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

INSERT INTO storage.objects VALUES ('ccd0ec40-af15-4df0-a210-47e20d837833', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b8da33c9-d361-4440-8046-1ee44481319c/050dca03-cc40-4c9d-bb43-027304f100a7/start.png', '8710590d-efde-4c63-99de-aba2014fe944', '2025-09-22 04:26:41.261115+00', '2025-09-22 04:26:41.261115+00', '2025-09-22 04:26:41.261115+00', '{"eTag": "\"96b629449b617b28e2b8c6bd5c0e3882\"", "size": 52147, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:26:42.000Z", "contentLength": 52147, "httpStatusCode": 200}', DEFAULT, '3e75de8d-ee35-49e7-b212-9dcb5bd71218', '8710590d-efde-4c63-99de-aba2014fe944', '{}', 4);
INSERT INTO storage.objects VALUES ('29591bda-29ca-4dcc-8a15-50a378019849', 'work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/completion/1758556612646_e2i3553a5ne.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:56:53.193259+00', '2025-09-22 15:56:53.193259+00', '2025-09-22 15:56:53.193259+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:56:53.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '78344a7b-2062-4eeb-b668-411feadd1101', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('d2384bce-3627-45e7-87a2-b28186dc7745', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/3106806e-4216-4301-92a6-cc88ee02261e/050dca03-cc40-4c9d-bb43-027304f100a7/end.png', '8710590d-efde-4c63-99de-aba2014fe944', '2025-09-22 04:31:05.016012+00', '2025-09-22 04:31:05.016012+00', '2025-09-22 04:31:05.016012+00', '{"eTag": "\"96b629449b617b28e2b8c6bd5c0e3882\"", "size": 52147, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:31:06.000Z", "contentLength": 52147, "httpStatusCode": 200}', DEFAULT, '1d6f0165-61ef-4d49-a6d3-62403b9cd77c', '8710590d-efde-4c63-99de-aba2014fe944', '{}', 4);
INSERT INTO storage.objects VALUES ('9205e613-1b31-4f43-9670-5ae3a22e54e3', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d4eee6b3-5b97-4098-83f9-85a9fc1acec5/050dca03-cc40-4c9d-bb43-027304f100a7/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:47:07.108418+00', '2025-09-22 04:47:07.108418+00', '2025-09-22 04:47:07.108418+00', '{"eTag": "\"274d95edc8adf5d2b8098dbd216093cf\"", "size": 698917, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:47:08.000Z", "contentLength": 698917, "httpStatusCode": 200}', DEFAULT, 'aceea480-52e6-4764-afc9-599f28163827', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('2c0c3649-1f14-49c9-aeac-a87a1d4f2369', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/9c7858dc-50b4-4b17-b3ad-ecdd11f6f0c7/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:48:54.995766+00', '2025-09-22 04:48:54.995766+00', '2025-09-22 04:48:54.995766+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:48:55.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '3ccdf2b8-ef33-4273-81f6-ce6547979014', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('0d6f5fe5-4db9-47ac-bdea-0cb5879ed326', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:05:59.875964+00', '2025-09-22 16:05:59.875964+00', '2025-09-22 16:05:59.875964+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T16:06:00.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '697b97d3-2518-4426-9d54-ec249b6e6bbf', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('2060e230-0481-4ffe-a602-d7ff27010596', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b4ec41c7-c060-4d5d-a16d-31cda9c04fb3/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:49:20.122645+00', '2025-09-22 04:49:20.122645+00', '2025-09-22 04:49:20.122645+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:49:21.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'd26401e1-d0ff-4883-9f50-8d40c923af36', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('30154af7-06af-4dec-a452-b190fb468920', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:06:00.11327+00', '2025-09-22 16:06:00.11327+00', '2025-09-22 16:06:00.11327+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T16:06:01.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, 'dee0098f-3f1a-42c7-8823-4c298e0bad77', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('dd275a5f-b615-49da-810f-75c2a6c7b782', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/01d6badc-70db-4a42-8f8d-5e7cf311aa36/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:49:57.949786+00', '2025-09-22 04:49:57.949786+00', '2025-09-22 04:49:57.949786+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:49:58.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '53414c44-8b83-4bde-a94f-49f73db39732', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('2af060d0-dc36-4549-9ef3-5ec24e6735d8', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/be5a5e91-6b88-4f59-b61a-fb260b0d48a3/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:52:29.412723+00', '2025-09-22 04:52:29.412723+00', '2025-09-22 04:52:29.412723+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:52:30.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '75be2f40-3737-48b1-b73e-fadb9f41e9d3', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('f2921a86-2ed4-464c-bf7a-db2d377e6986', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/76adf87f-5ec6-4031-a4e6-8545360926cf/e01e7210-8053-4f54-830f-dc51c634154c/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:58:02.983678+00', '2025-09-22 04:58:02.983678+00', '2025-09-22 04:58:02.983678+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:58:03.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, 'e516cf8c-85f9-448c-a161-d1f86687cbd0', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('c5d9ca6c-867c-4862-b6aa-768b513a3d23', 'work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/f38ed7dc-4d0a-4a2b-bf4a-e1eecd0371d7/95af0801-eabc-4d0a-a90d-c26deed08467/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:19:52.346179+00', '2025-09-22 16:19:52.346179+00', '2025-09-22 16:19:52.346179+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T16:19:53.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'b4ea2afe-b5c8-474b-b9b8-646052c16ab1', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('49dba561-28ee-4b9a-b7b1-a0474c8b34ea', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70/e01e7210-8053-4f54-830f-dc51c634154c/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:58:43.26277+00', '2025-09-22 04:58:43.26277+00', '2025-09-22 04:58:43.26277+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:58:44.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '7bdf6f92-374e-4ad4-b7a5-ac524788b03d', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('f1ae5ee3-55c4-49f1-a1e1-a2ce8bad68d9', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/4c0b6f8e-c878-445c-ae75-ce4483c0ec98/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:52:29.438651+00', '2025-09-22 04:52:29.438651+00', '2025-09-22 04:52:29.438651+00', '{"eTag": "\"4fdb3cffe14dab4ac017cbde8e713d23\"", "size": 1062437, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:52:30.000Z", "contentLength": 1062437, "httpStatusCode": 200}', DEFAULT, '5cf042da-a51c-4c4a-9083-1def5df4513d', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('056e3fe7-9f7b-4fdb-bad4-cd0a93ca71d1', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/756f4a4d-91e9-4b98-a198-a2974617cadd/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:52:29.974818+00', '2025-09-22 04:52:29.974818+00', '2025-09-22 04:52:29.974818+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:52:30.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, 'd22eae6f-2ef5-476f-b6fa-006b0908f8fb', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('aeb60f0d-ef5e-4c2b-8ec5-f454c65fb412', 'work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/33ae8e85-062b-4bd7-84e2-39f3f0635aae/95af0801-eabc-4d0a-a90d-c26deed08467/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:20:02.297901+00', '2025-09-22 16:20:02.297901+00', '2025-09-22 16:20:02.297901+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T16:20:03.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '04cbaacf-0ca1-4a7d-9166-20dfd24499b8', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('c5fe90f8-0533-4e5e-bc37-f2a34ecb886b', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/be5a5e91-6b88-4f59-b61a-fb260b0d48a3/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:56:50.539482+00', '2025-09-22 04:56:50.539482+00', '2025-09-22 04:56:50.539482+00', '{"eTag": "\"4fdb3cffe14dab4ac017cbde8e713d23\"", "size": 1062437, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:56:51.000Z", "contentLength": 1062437, "httpStatusCode": 200}', DEFAULT, '17f61ad2-a9ac-44d6-a71e-591bbf0c1101', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('262e05c8-ddca-4e3d-a2c4-5779a73dbb6d', 'work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/cancellation/1758558025313_8b4q3xz317d.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 16:20:26.141584+00', '2025-09-22 16:20:26.141584+00', '2025-09-22 16:20:26.141584+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T16:20:27.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '26c14cf2-1b1c-44f7-8b96-4c061c87734e', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('2df61b03-cff1-4993-bef9-781e9f1379e5', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/4c0b6f8e-c878-445c-ae75-ce4483c0ec98/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:56:50.807949+00', '2025-09-22 04:56:50.807949+00', '2025-09-22 04:56:50.807949+00', '{"eTag": "\"9730d8259e692df399084afba4b3a6f6\"", "size": 3023718, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:56:51.000Z", "contentLength": 3023718, "httpStatusCode": 200}', DEFAULT, '4072b6a8-932e-4521-81e7-bdef3619742a', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('455e5dfe-6b8d-4969-bb73-28e82466d785', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/756f4a4d-91e9-4b98-a198-a2974617cadd/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:56:51.119595+00', '2025-09-22 04:56:51.119595+00', '2025-09-22 04:56:51.119595+00', '{"eTag": "\"94e99e661fcc3be4d2aee3e6a59a4969\"", "size": 3881277, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:56:52.000Z", "contentLength": 3881277, "httpStatusCode": 200}', DEFAULT, '29fc5024-68cd-4878-aea1-63a87444e0d5', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('b7d7a414-981e-46b2-8bd7-99ca2332aa50', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/950cf104-7cbb-4586-9048-0265e422a677/b1e0e3cc-adbf-4949-9992-84b0deccb870/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:59:05.316851+00', '2025-09-22 04:59:05.316851+00', '2025-09-22 04:59:05.316851+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:59:06.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, 'e05c80f5-a6be-499d-848b-78faa7a92464', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('3e006e7e-b199-436d-80dd-34908e3d78b9', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 04:59:48.787512+00', '2025-09-22 04:59:48.787512+00', '2025-09-22 04:59:48.787512+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T04:59:49.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '2f255c5b-5b27-4726-a362-58bd7558c1a8', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('85438cdb-308f-4147-b5b6-6cb2b2f4fdd9', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/cancellation/1758517276541_0qww2mt5ox8b.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:01:16.864209+00', '2025-09-22 05:01:16.864209+00', '2025-09-22 05:01:16.864209+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:01:17.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '4399f25b-efe7-4bec-90d4-43178aa80d79', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('5e4ef6b6-668d-4fd2-a799-ad5178625bec', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/fd3d2161-5516-459c-bedb-1851d1dfc389/50a08ed9-e6a3-484c-8f7b-ea068255bbee/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:07:22.08782+00', '2025-09-22 05:07:22.08782+00', '2025-09-22 05:07:22.08782+00', '{"eTag": "\"ca934f7777a09cd2aa4d3a152f7e2fbb\"", "size": 1867401, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:07:23.000Z", "contentLength": 1867401, "httpStatusCode": 200}', DEFAULT, '2fe90e9c-4e97-4031-95ee-3459adb613c7', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('bab1231d-c056-41cd-9ed8-d84d9938d693', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/7d6a7dd8-1d6c-4078-b35f-5576b77fa594/50a08ed9-e6a3-484c-8f7b-ea068255bbee/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:07:53.950838+00', '2025-09-22 05:07:53.950838+00', '2025-09-22 05:07:53.950838+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:07:54.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, 'a31e2302-37db-4d50-a35b-b1d5333d784e', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('20ac8bb2-c370-49e9-b9be-afeb7737df2f', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/07a55ba8-bb1f-48f3-b8a8-82d4059d140b/b1e0e3cc-adbf-4949-9992-84b0deccb870/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:09:21.547338+00', '2025-09-22 05:09:21.547338+00', '2025-09-22 05:09:21.547338+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:09:22.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '76570847-a7f8-4b38-b7a9-6e77b474b43e', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('226e2afe-2cde-41da-9ef0-f13b6069a94c', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d33efa7e-216b-40d1-96ab-2084a642c116/da219c16-9450-4eb9-b456-6257866ea0f4/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:09:36.526247+00', '2025-09-22 05:09:36.526247+00', '2025-09-22 05:09:36.526247+00', '{"eTag": "\"77573ba36286d869de99d7a449e344ce\"", "size": 1346167, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:09:37.000Z", "contentLength": 1346167, "httpStatusCode": 200}', DEFAULT, 'ee21458b-07fe-4825-9e95-9b9adc951a77', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('b2e8179e-30ee-44d0-be63-523b6703981c', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8d790d31-9f37-43d9-baae-15a8ea9f4b3f/da219c16-9450-4eb9-b456-6257866ea0f4/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:09:43.622645+00', '2025-09-22 05:09:43.622645+00', '2025-09-22 05:09:43.622645+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:09:44.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '10e0292c-6b80-46b1-bfa8-1afbcf79025f', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('a48ac45b-9d8c-4e78-8717-fe896031ea55', 'work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/completion/1758517980444_odc1c9etqcs.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 05:13:00.455928+00', '2025-09-22 05:13:00.455928+00', '2025-09-22 05:13:00.455928+00', '{"eTag": "\"eb22ad7736a934bd94674b8f96a478d4\"", "size": 686345, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T05:13:01.000Z", "contentLength": 686345, "httpStatusCode": 200}', DEFAULT, '0c767440-bde1-45e1-84e7-40b36fbb4863', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('fcdedb7f-ca08-4e12-853d-99511c45e54c', 'work-proofs', '79479fa1-89a1-464f-987e-ba80d33f0c81/cancellation/1758553099958_zase2w8g2j.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 14:58:20.48891+00', '2025-09-22 14:58:20.48891+00', '2025-09-22 14:58:20.48891+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T14:58:21.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '9d68ff2e-0e8e-4bc8-a76b-3881faf3f6da', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('899a2fbd-6e39-4ce3-be44-7ec91c468978', 'work-proofs', '99845878-ad7d-4520-a213-cfcfbca9b2e6/a5adadbb-e037-492c-b9ff-4dd88e54db1a/774a71a6-c241-4de3-b2e2-ec9d71dc93f6/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 14:58:50.03841+00', '2025-09-22 14:58:50.03841+00', '2025-09-22 14:58:50.03841+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T14:58:50.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '91669470-8c62-4eca-8f74-c49186ec7a44', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('5ed6c580-5dc1-4bfd-911b-b47529987d56', 'work-proofs', '0f442910-726b-4f8a-9419-c3480a842990/5ec3f70c-fb38-4d3d-8182-f2aa3ab2e6ff/3afe836b-e565-4953-93d2-661d0878bbb2/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 14:59:25.722291+00', '2025-09-22 14:59:25.722291+00', '2025-09-22 14:59:25.722291+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T14:59:26.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '365adfb4-6dba-4df1-9dbf-f34126677950', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('97f916b9-b117-4165-9cbf-d92996c4c7a7', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/8f4f965b-d8f1-492c-bde2-078fcb0143e8/0d01aae9-382e-42fc-aa39-754adfd5f28c/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:16:07.470945+00', '2025-09-22 15:16:07.470945+00', '2025-09-22 15:16:07.470945+00', '{"eTag": "\"77573ba36286d869de99d7a449e344ce\"", "size": 1346167, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:16:08.000Z", "contentLength": 1346167, "httpStatusCode": 200}', DEFAULT, 'e8feb47a-ca7f-4635-b698-ee81cfd93314', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('2ff7066a-1997-4f49-825b-86872baf938a', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/a1578e42-1295-4110-833a-ebbe7da74534/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:16:52.239359+00', '2025-09-22 15:16:52.239359+00', '2025-09-22 15:16:52.239359+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:16:53.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '84727f0e-2902-4a3c-8fea-074e0ac5db01', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('abdd32bd-7db9-45af-98c8-0aaf72a1cfc1', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/cancellation/1758554310097_idnyb23i8j.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:18:30.782037+00', '2025-09-22 15:18:30.782037+00', '2025-09-22 15:18:30.782037+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:18:31.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '44bfff43-5fe1-42bb-916b-3036ada3d0b6', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('1dae2d86-1b84-4762-9a17-b8d23d80124b', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/dc3826a9-be41-46a8-942c-d56779e18475/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:20:26.434619+00', '2025-09-22 15:20:26.434619+00', '2025-09-22 15:20:26.434619+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:20:27.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '9878e71c-e782-45e1-9344-026f331138c1', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('7f660234-a7aa-4bfc-bc39-6a2197d8d58c', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/677dbd59-b91a-4de9-9504-d00d7d429b53/0d01aae9-382e-42fc-aa39-754adfd5f28c/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:21:04.466032+00', '2025-09-22 15:21:04.466032+00', '2025-09-22 15:21:04.466032+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:21:05.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '160f7420-3fc0-4b66-8420-422202f4a363', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('16b2a798-e5ff-4cd1-b313-5064d6d359c3', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/e86c5a8c-ae52-4503-81a4-2d3b6024e303/47bcf011-8161-430f-966e-f6b6f2a7c92a/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:21:30.491547+00', '2025-09-22 15:21:30.491547+00', '2025-09-22 15:21:30.491547+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:21:31.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, 'a35da961-a0d6-4639-9248-d389ebae5a70', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('a15cbb3b-553f-4911-8ac2-cf438fd93644', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/24c58bad-f4c7-4aa4-abf4-e23854867c34/47bcf011-8161-430f-966e-f6b6f2a7c92a/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:22:09.538733+00', '2025-09-22 15:22:09.538733+00', '2025-09-22 15:22:09.538733+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:22:10.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '181ae7f4-a0a7-4ad6-a7e7-70c0bd2edf37', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('63a7cb73-6378-4e9d-9d6e-320f53e116be', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/245337b1-6e94-4932-a4f3-a2754d99dcb3/e84b5499-2d23-48b3-9d18-347630e09cc1/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:23:13.514392+00', '2025-09-22 15:23:13.514392+00', '2025-09-22 15:23:13.514392+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:23:14.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'ac199e0d-d241-4d04-b996-9576f571b3e2', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('76b3dbf9-d80e-4cee-b971-4e9e0eda89f1', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/01a2becf-2c47-4508-b738-aa03392c73c6/e84b5499-2d23-48b3-9d18-347630e09cc1/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:23:31.760573+00', '2025-09-22 15:23:31.760573+00', '2025-09-22 15:23:31.760573+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:23:32.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '2c8ce907-0665-41ad-bb82-5bf5b6f4cde8', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('c0d052dc-30fc-4790-89c4-959c25fb1208', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/completion/1758554711076_vxs42ttfxus.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:25:11.642079+00', '2025-09-22 15:25:11.642079+00', '2025-09-22 15:25:11.642079+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:25:12.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '2576422a-b48f-4099-a99e-17387e97cbc1', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('50f26600-1636-4e7b-a14f-73f67cd291f4', 'work-proofs', '7b637335-aa61-429b-97be-092c438427ee/completion/1758554881806_l9xarfthlp.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:28:02.346183+00', '2025-09-22 15:28:02.346183+00', '2025-09-22 15:28:02.346183+00', '{"eTag": "\"77573ba36286d869de99d7a449e344ce\"", "size": 1346167, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:28:03.000Z", "contentLength": 1346167, "httpStatusCode": 200}', DEFAULT, 'fd375b6f-f429-423d-9d69-f4d7f7325580', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 3);
INSERT INTO storage.objects VALUES ('06b94845-dd8c-4752-a1a0-390c9a4e450e', 'work-proofs', '88162217-4bce-4014-aec7-466508a9ec43/7bc93758-4400-4996-905d-7eabd8dbe6f2/47c23563-689a-4fbd-b3a4-134204fb4f34/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:40:27.509861+00', '2025-09-22 15:40:27.509861+00', '2025-09-22 15:40:27.509861+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:40:28.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, 'b4a0b506-d088-4fc7-83ba-4ffd4e6a1ef7', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('aea4c27f-eb73-4a4c-b9d2-766135eae67e', 'work-proofs', '88162217-4bce-4014-aec7-466508a9ec43/eaa3d558-37dc-49a5-972e-e550975fcb9a/47c23563-689a-4fbd-b3a4-134204fb4f34/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:40:50.05749+00', '2025-09-22 15:40:50.05749+00', '2025-09-22 15:40:50.05749+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:40:51.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '8bbdbf45-e3fd-4744-99fc-0e01d91306ee', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('982fef54-9627-4284-95fd-7d8b701e55e6', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/8fabd6a2-f160-4012-8712-d7184c305648/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:43:45.553958+00', '2025-09-22 15:43:45.553958+00', '2025-09-22 15:43:45.553958+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:43:46.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '3802da77-0bf4-49d3-aa27-ff477ecc0afa', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('4bcfbb21-9e83-4bfa-8899-f6c9e93ff2b5', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:43:45.865198+00', '2025-09-22 15:43:45.865198+00', '2025-09-22 15:43:45.865198+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:43:46.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'a18cdd4a-887c-493c-a99a-d324c010e865', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('b03384ae-f64e-45df-b90b-27a9b939dead', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:43:45.89149+00', '2025-09-22 15:43:45.89149+00', '2025-09-22 15:43:45.89149+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:43:46.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '4e50543c-e86d-443f-9147-691e00bbeb75', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('d335a4d2-3604-4e01-bae8-c51fa7bdc6ae', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/ffcb84f5-c839-4efe-be8c-40f4888ca3b0/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:44:24.997106+00', '2025-09-22 15:44:24.997106+00', '2025-09-22 15:44:24.997106+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:44:25.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '33a6d550-8a15-41d2-b143-20a9b7621564', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('d17a891b-7e8a-45de-8d63-dcaf52498ced', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/6f8542b1-7c2a-47be-922f-d8059d9d8a9c/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:44:25.449108+00', '2025-09-22 15:44:25.449108+00', '2025-09-22 15:44:25.449108+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:44:26.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'e4d72182-af3a-4038-a6c3-df5bd8d3d8db', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('89c817c4-3402-4af9-be27-cd3e86017150', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/6b62abff-c3b3-4000-a64f-8d390953812c/8fabd6a2-f160-4012-8712-d7184c305648/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:44:42.903369+00', '2025-09-22 15:44:42.903369+00', '2025-09-22 15:44:42.903369+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:44:43.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'ea971a0d-5fd1-4c22-8fd7-a83139da764b', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('b3bab772-fb3f-4708-b641-a0d64a601fec', 'work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/d15a29ac-bc79-4d55-829d-37119aa66129/8fabd6a2-f160-4012-8712-d7184c305648/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:45:01.593586+00', '2025-09-22 15:45:01.593586+00', '2025-09-22 15:45:01.593586+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:45:02.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '20c3e35e-8d5d-4b6c-a29d-5b166a26e647', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('7715148c-39ed-43f7-90e4-4fdc56681b5b', 'work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/aaed1730-ff56-4ccb-a924-66f78ad71267/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:46:38.854621+00', '2025-09-22 15:46:38.854621+00', '2025-09-22 15:46:38.854621+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:46:39.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '5b4cb2f8-bec9-4701-8d24-317503dd56c4', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('35535f24-2f9c-47f4-a52e-fe94007064a0', 'work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/86087992-d92f-48b4-aa56-38ca5b84a27c/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:48:22.477748+00', '2025-09-22 15:48:22.477748+00', '2025-09-22 15:48:22.477748+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:48:23.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '4a883a4c-2424-4da4-ac6b-f45d2754a15e', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('c40432ce-11b7-4786-ae8a-512557fffeda', 'work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/8d9d474b-c5f6-4aeb-8fec-6686ea3f4cad/ba293e3e-ce8d-472b-b27e-ea4d96616f3b/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:48:50.905927+00', '2025-09-22 15:48:50.905927+00', '2025-09-22 15:48:50.905927+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:48:51.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, '8f520bd3-7ae8-4f68-bc85-6cd6ec14d19a', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('07c68d06-3767-47a6-85d7-8a8f2493f4a5', 'work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/7b9b7c9d-681b-4817-883b-683637d8e3f8/ba293e3e-ce8d-472b-b27e-ea4d96616f3b/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:48:57.675034+00', '2025-09-22 15:48:57.675034+00', '2025-09-22 15:48:57.675034+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:48:58.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '31109960-78e8-4b33-8da2-4b0d389126ce', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('2adce811-c1a1-4d8f-b482-8c148b1415aa', 'work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/cc5e09ed-8248-4d85-ad83-f0a963b124eb/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:55:56.308858+00', '2025-09-22 15:55:56.308858+00', '2025-09-22 15:55:56.308858+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:55:57.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, '5186e9c0-6609-49a1-9b05-aae7df387900', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('a5131b58-7d09-4607-8a51-24388a11f721', 'work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/499ffbcf-53c1-48cc-9d0d-4332be499dc1/start.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:55:56.338057+00', '2025-09-22 15:55:56.338057+00', '2025-09-22 15:55:56.338057+00', '{"eTag": "\"dde8262991aba4ae66f5fa17f70df708\"", "size": 2328834, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:55:57.000Z", "contentLength": 2328834, "httpStatusCode": 200}', DEFAULT, 'f3c90698-4a9c-4173-ae41-ea32a2ffbec5', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('4b903a68-7bfa-4603-b868-a68665cb8f15', 'work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2/499ffbcf-53c1-48cc-9d0d-4332be499dc1/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:56:22.399377+00', '2025-09-22 15:56:22.399377+00', '2025-09-22 15:56:22.399377+00', '{"eTag": "\"76ee831e74528f31fb4da70df9a8734a\"", "size": 881701, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:56:23.000Z", "contentLength": 881701, "httpStatusCode": 200}', DEFAULT, '9ae5d14a-673b-48da-b5e9-6e08e265a4dd', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);
INSERT INTO storage.objects VALUES ('bd0b5bc7-ae5d-4799-ae04-7676bb7157a1', 'work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2/cc5e09ed-8248-4d85-ad83-f0a963b124eb/end.png', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '2025-09-22 15:56:22.726373+00', '2025-09-22 15:56:22.726373+00', '2025-09-22 15:56:22.726373+00', '{"eTag": "\"c5d8c1b21a4b9bedfc82db4acd1f9d6d\"", "size": 3514842, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-22T15:56:23.000Z", "contentLength": 3514842, "httpStatusCode": 200}', DEFAULT, 'bc0072d5-5b15-41e3-a0b5-68babcc0ffaf', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '{}', 4);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: -
--

INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/01d6badc-70db-4a42-8f8d-5e7cf311aa36', DEFAULT, '2025-09-22 04:49:57.949786+00', '2025-09-22 04:49:57.949786+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/01d6badc-70db-4a42-8f8d-5e7cf311aa36/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', DEFAULT, '2025-09-22 04:49:57.949786+00', '2025-09-22 04:49:57.949786+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/4c0b6f8e-c878-445c-ae75-ce4483c0ec98', DEFAULT, '2025-09-22 04:52:29.438651+00', '2025-09-22 04:52:29.438651+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/756f4a4d-91e9-4b98-a198-a2974617cadd', DEFAULT, '2025-09-22 04:52:29.974818+00', '2025-09-22 04:52:29.974818+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5', DEFAULT, '2025-09-22 04:56:50.539482+00', '2025-09-22 04:56:50.539482+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/be5a5e91-6b88-4f59-b61a-fb260b0d48a3', DEFAULT, '2025-09-22 04:56:50.539482+00', '2025-09-22 04:56:50.539482+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d', DEFAULT, '2025-09-22 15:43:45.553958+00', '2025-09-22 15:43:45.553958+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/4c0b6f8e-c878-445c-ae75-ce4483c0ec98', DEFAULT, '2025-09-22 04:56:50.807949+00', '2025-09-22 04:56:50.807949+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/6fbe7bbe-d241-4b8e-8a5d-ac135dc3fae5/756f4a4d-91e9-4b98-a198-a2974617cadd', DEFAULT, '2025-09-22 04:56:51.119595+00', '2025-09-22 04:56:51.119595+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881', DEFAULT, '2025-09-22 15:43:45.553958+00', '2025-09-22 15:43:45.553958+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/8fabd6a2-f160-4012-8712-d7184c305648', DEFAULT, '2025-09-22 15:43:45.553958+00', '2025-09-22 15:43:45.553958+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/950cf104-7cbb-4586-9048-0265e422a677', DEFAULT, '2025-09-22 04:59:05.316851+00', '2025-09-22 04:59:05.316851+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/950cf104-7cbb-4586-9048-0265e422a677/b1e0e3cc-adbf-4949-9992-84b0deccb870', DEFAULT, '2025-09-22 04:59:05.316851+00', '2025-09-22 04:59:05.316851+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/6f8542b1-7c2a-47be-922f-d8059d9d8a9c', DEFAULT, '2025-09-22 15:43:45.865198+00', '2025-09-22 15:43:45.865198+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/a92dde21-1e78-435c-9669-4f2501ec7881/ffcb84f5-c839-4efe-be8c-40f4888ca3b0', DEFAULT, '2025-09-22 15:43:45.89149+00', '2025-09-22 15:43:45.89149+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb', DEFAULT, '2025-09-22 04:59:48.787512+00', '2025-09-22 04:59:48.787512+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8df4b0c5-8f4b-4e63-9399-41d7acf998fb/b1e0e3cc-adbf-4949-9992-84b0deccb870', DEFAULT, '2025-09-22 04:59:48.787512+00', '2025-09-22 04:59:48.787512+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/cancellation', DEFAULT, '2025-09-22 05:01:16.864209+00', '2025-09-22 05:01:16.864209+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/fd3d2161-5516-459c-bedb-1851d1dfc389', DEFAULT, '2025-09-22 05:07:22.08782+00', '2025-09-22 05:07:22.08782+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/fd3d2161-5516-459c-bedb-1851d1dfc389/50a08ed9-e6a3-484c-8f7b-ea068255bbee', DEFAULT, '2025-09-22 05:07:22.08782+00', '2025-09-22 05:07:22.08782+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/7d6a7dd8-1d6c-4078-b35f-5576b77fa594', DEFAULT, '2025-09-22 05:07:53.950838+00', '2025-09-22 05:07:53.950838+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/7d6a7dd8-1d6c-4078-b35f-5576b77fa594/50a08ed9-e6a3-484c-8f7b-ea068255bbee', DEFAULT, '2025-09-22 05:07:53.950838+00', '2025-09-22 05:07:53.950838+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6', DEFAULT, '2025-09-22 16:19:52.346179+00', '2025-09-22 16:19:52.346179+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/07a55ba8-bb1f-48f3-b8a8-82d4059d140b', DEFAULT, '2025-09-22 05:09:21.547338+00', '2025-09-22 05:09:21.547338+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/07a55ba8-bb1f-48f3-b8a8-82d4059d140b/b1e0e3cc-adbf-4949-9992-84b0deccb870', DEFAULT, '2025-09-22 05:09:21.547338+00', '2025-09-22 05:09:21.547338+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/f38ed7dc-4d0a-4a2b-bf4a-e1eecd0371d7', DEFAULT, '2025-09-22 16:19:52.346179+00', '2025-09-22 16:19:52.346179+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/f38ed7dc-4d0a-4a2b-bf4a-e1eecd0371d7/95af0801-eabc-4d0a-a90d-c26deed08467', DEFAULT, '2025-09-22 16:19:52.346179+00', '2025-09-22 16:19:52.346179+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d33efa7e-216b-40d1-96ab-2084a642c116', DEFAULT, '2025-09-22 05:09:36.526247+00', '2025-09-22 05:09:36.526247+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d33efa7e-216b-40d1-96ab-2084a642c116/da219c16-9450-4eb9-b456-6257866ea0f4', DEFAULT, '2025-09-22 05:09:36.526247+00', '2025-09-22 05:09:36.526247+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd', DEFAULT, '2025-09-22 04:26:41.261115+00', '2025-09-22 04:26:41.261115+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b8da33c9-d361-4440-8046-1ee44481319c', DEFAULT, '2025-09-22 04:26:41.261115+00', '2025-09-22 04:26:41.261115+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b8da33c9-d361-4440-8046-1ee44481319c/050dca03-cc40-4c9d-bb43-027304f100a7', DEFAULT, '2025-09-22 04:26:41.261115+00', '2025-09-22 04:26:41.261115+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/3106806e-4216-4301-92a6-cc88ee02261e', DEFAULT, '2025-09-22 04:31:05.016012+00', '2025-09-22 04:31:05.016012+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/3106806e-4216-4301-92a6-cc88ee02261e/050dca03-cc40-4c9d-bb43-027304f100a7', DEFAULT, '2025-09-22 04:31:05.016012+00', '2025-09-22 04:31:05.016012+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d4eee6b3-5b97-4098-83f9-85a9fc1acec5', DEFAULT, '2025-09-22 04:47:07.108418+00', '2025-09-22 04:47:07.108418+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/d4eee6b3-5b97-4098-83f9-85a9fc1acec5/050dca03-cc40-4c9d-bb43-027304f100a7', DEFAULT, '2025-09-22 04:47:07.108418+00', '2025-09-22 04:47:07.108418+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/9c7858dc-50b4-4b17-b3ad-ecdd11f6f0c7', DEFAULT, '2025-09-22 04:48:54.995766+00', '2025-09-22 04:48:54.995766+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/9c7858dc-50b4-4b17-b3ad-ecdd11f6f0c7/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', DEFAULT, '2025-09-22 04:48:54.995766+00', '2025-09-22 04:48:54.995766+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b4ec41c7-c060-4d5d-a16d-31cda9c04fb3', DEFAULT, '2025-09-22 04:49:20.122645+00', '2025-09-22 04:49:20.122645+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/b4ec41c7-c060-4d5d-a16d-31cda9c04fb3/e47d65bd-bbcf-4095-aeb6-017da7e7e9c0', DEFAULT, '2025-09-22 04:49:20.122645+00', '2025-09-22 04:49:20.122645+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2', DEFAULT, '2025-09-22 15:44:24.997106+00', '2025-09-22 15:44:24.997106+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f', DEFAULT, '2025-09-22 04:52:29.412723+00', '2025-09-22 04:52:29.412723+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/4108fd0a-82c9-49bb-8bf2-5eb0fc3b042f/be5a5e91-6b88-4f59-b61a-fb260b0d48a3', DEFAULT, '2025-09-22 04:52:29.412723+00', '2025-09-22 04:52:29.412723+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/ffcb84f5-c839-4efe-be8c-40f4888ca3b0', DEFAULT, '2025-09-22 15:44:24.997106+00', '2025-09-22 15:44:24.997106+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/76adf87f-5ec6-4031-a4e6-8545360926cf', DEFAULT, '2025-09-22 04:58:02.983678+00', '2025-09-22 04:58:02.983678+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/76adf87f-5ec6-4031-a4e6-8545360926cf/e01e7210-8053-4f54-830f-dc51c634154c', DEFAULT, '2025-09-22 04:58:02.983678+00', '2025-09-22 04:58:02.983678+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/f674a516-1e74-4caa-8bb8-bbb36f4fd8d2/6f8542b1-7c2a-47be-922f-d8059d9d8a9c', DEFAULT, '2025-09-22 15:44:25.449108+00', '2025-09-22 15:44:25.449108+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70', DEFAULT, '2025-09-22 04:58:43.26277+00', '2025-09-22 04:58:43.26277+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/bfc0fd51-e224-42d5-b9b5-cb4c8e0c1c70/e01e7210-8053-4f54-830f-dc51c634154c', DEFAULT, '2025-09-22 04:58:43.26277+00', '2025-09-22 04:58:43.26277+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8d790d31-9f37-43d9-baae-15a8ea9f4b3f', DEFAULT, '2025-09-22 05:09:43.622645+00', '2025-09-22 05:09:43.622645+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/8d790d31-9f37-43d9-baae-15a8ea9f4b3f/da219c16-9450-4eb9-b456-6257866ea0f4', DEFAULT, '2025-09-22 05:09:43.622645+00', '2025-09-22 05:09:43.622645+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/6b62abff-c3b3-4000-a64f-8d390953812c', DEFAULT, '2025-09-22 15:44:42.903369+00', '2025-09-22 15:44:42.903369+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '8dfc9b36-72c5-4a82-9f2d-5569c0d6c5fd/completion', DEFAULT, '2025-09-22 05:13:00.455928+00', '2025-09-22 05:13:00.455928+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/6b62abff-c3b3-4000-a64f-8d390953812c/8fabd6a2-f160-4012-8712-d7184c305648', DEFAULT, '2025-09-22 15:44:42.903369+00', '2025-09-22 15:44:42.903369+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '79479fa1-89a1-464f-987e-ba80d33f0c81', DEFAULT, '2025-09-22 14:58:20.48891+00', '2025-09-22 14:58:20.48891+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '79479fa1-89a1-464f-987e-ba80d33f0c81/cancellation', DEFAULT, '2025-09-22 14:58:20.48891+00', '2025-09-22 14:58:20.48891+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/d15a29ac-bc79-4d55-829d-37119aa66129', DEFAULT, '2025-09-22 15:45:01.593586+00', '2025-09-22 15:45:01.593586+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '99845878-ad7d-4520-a213-cfcfbca9b2e6', DEFAULT, '2025-09-22 14:58:50.03841+00', '2025-09-22 14:58:50.03841+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '99845878-ad7d-4520-a213-cfcfbca9b2e6/a5adadbb-e037-492c-b9ff-4dd88e54db1a', DEFAULT, '2025-09-22 14:58:50.03841+00', '2025-09-22 14:58:50.03841+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '99845878-ad7d-4520-a213-cfcfbca9b2e6/a5adadbb-e037-492c-b9ff-4dd88e54db1a/774a71a6-c241-4de3-b2e2-ec9d71dc93f6', DEFAULT, '2025-09-22 14:58:50.03841+00', '2025-09-22 14:58:50.03841+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '0f442910-726b-4f8a-9419-c3480a842990', DEFAULT, '2025-09-22 14:59:25.722291+00', '2025-09-22 14:59:25.722291+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '0f442910-726b-4f8a-9419-c3480a842990/5ec3f70c-fb38-4d3d-8182-f2aa3ab2e6ff', DEFAULT, '2025-09-22 14:59:25.722291+00', '2025-09-22 14:59:25.722291+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '0f442910-726b-4f8a-9419-c3480a842990/5ec3f70c-fb38-4d3d-8182-f2aa3ab2e6ff/3afe836b-e565-4953-93d2-661d0878bbb2', DEFAULT, '2025-09-22 14:59:25.722291+00', '2025-09-22 14:59:25.722291+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee', DEFAULT, '2025-09-22 15:16:07.470945+00', '2025-09-22 15:16:07.470945+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/8f4f965b-d8f1-492c-bde2-078fcb0143e8', DEFAULT, '2025-09-22 15:16:07.470945+00', '2025-09-22 15:16:07.470945+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/8f4f965b-d8f1-492c-bde2-078fcb0143e8/0d01aae9-382e-42fc-aa39-754adfd5f28c', DEFAULT, '2025-09-22 15:16:07.470945+00', '2025-09-22 15:16:07.470945+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/a1578e42-1295-4110-833a-ebbe7da74534', DEFAULT, '2025-09-22 15:16:52.239359+00', '2025-09-22 15:16:52.239359+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/a1578e42-1295-4110-833a-ebbe7da74534/0d01aae9-382e-42fc-aa39-754adfd5f28c', DEFAULT, '2025-09-22 15:16:52.239359+00', '2025-09-22 15:16:52.239359+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/cancellation', DEFAULT, '2025-09-22 15:18:30.782037+00', '2025-09-22 15:18:30.782037+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/dc3826a9-be41-46a8-942c-d56779e18475', DEFAULT, '2025-09-22 15:20:26.434619+00', '2025-09-22 15:20:26.434619+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/dc3826a9-be41-46a8-942c-d56779e18475/0d01aae9-382e-42fc-aa39-754adfd5f28c', DEFAULT, '2025-09-22 15:20:26.434619+00', '2025-09-22 15:20:26.434619+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/677dbd59-b91a-4de9-9504-d00d7d429b53', DEFAULT, '2025-09-22 15:21:04.466032+00', '2025-09-22 15:21:04.466032+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/677dbd59-b91a-4de9-9504-d00d7d429b53/0d01aae9-382e-42fc-aa39-754adfd5f28c', DEFAULT, '2025-09-22 15:21:04.466032+00', '2025-09-22 15:21:04.466032+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/e86c5a8c-ae52-4503-81a4-2d3b6024e303', DEFAULT, '2025-09-22 15:21:30.491547+00', '2025-09-22 15:21:30.491547+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/e86c5a8c-ae52-4503-81a4-2d3b6024e303/47bcf011-8161-430f-966e-f6b6f2a7c92a', DEFAULT, '2025-09-22 15:21:30.491547+00', '2025-09-22 15:21:30.491547+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/24c58bad-f4c7-4aa4-abf4-e23854867c34', DEFAULT, '2025-09-22 15:22:09.538733+00', '2025-09-22 15:22:09.538733+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/24c58bad-f4c7-4aa4-abf4-e23854867c34/47bcf011-8161-430f-966e-f6b6f2a7c92a', DEFAULT, '2025-09-22 15:22:09.538733+00', '2025-09-22 15:22:09.538733+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/245337b1-6e94-4932-a4f3-a2754d99dcb3', DEFAULT, '2025-09-22 15:23:13.514392+00', '2025-09-22 15:23:13.514392+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/245337b1-6e94-4932-a4f3-a2754d99dcb3/e84b5499-2d23-48b3-9d18-347630e09cc1', DEFAULT, '2025-09-22 15:23:13.514392+00', '2025-09-22 15:23:13.514392+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/01a2becf-2c47-4508-b738-aa03392c73c6', DEFAULT, '2025-09-22 15:23:31.760573+00', '2025-09-22 15:23:31.760573+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/01a2becf-2c47-4508-b738-aa03392c73c6/e84b5499-2d23-48b3-9d18-347630e09cc1', DEFAULT, '2025-09-22 15:23:31.760573+00', '2025-09-22 15:23:31.760573+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '7b637335-aa61-429b-97be-092c438427ee/completion', DEFAULT, '2025-09-22 15:25:11.642079+00', '2025-09-22 15:25:11.642079+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '88162217-4bce-4014-aec7-466508a9ec43', DEFAULT, '2025-09-22 15:40:27.509861+00', '2025-09-22 15:40:27.509861+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '88162217-4bce-4014-aec7-466508a9ec43/7bc93758-4400-4996-905d-7eabd8dbe6f2', DEFAULT, '2025-09-22 15:40:27.509861+00', '2025-09-22 15:40:27.509861+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '88162217-4bce-4014-aec7-466508a9ec43/7bc93758-4400-4996-905d-7eabd8dbe6f2/47c23563-689a-4fbd-b3a4-134204fb4f34', DEFAULT, '2025-09-22 15:40:27.509861+00', '2025-09-22 15:40:27.509861+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/d15a29ac-bc79-4d55-829d-37119aa66129/8fabd6a2-f160-4012-8712-d7184c305648', DEFAULT, '2025-09-22 15:45:01.593586+00', '2025-09-22 15:45:01.593586+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '88162217-4bce-4014-aec7-466508a9ec43/eaa3d558-37dc-49a5-972e-e550975fcb9a', DEFAULT, '2025-09-22 15:40:50.05749+00', '2025-09-22 15:40:50.05749+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '88162217-4bce-4014-aec7-466508a9ec43/eaa3d558-37dc-49a5-972e-e550975fcb9a/47c23563-689a-4fbd-b3a4-134204fb4f34', DEFAULT, '2025-09-22 15:40:50.05749+00', '2025-09-22 15:40:50.05749+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653', DEFAULT, '2025-09-22 15:46:38.854621+00', '2025-09-22 15:46:38.854621+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/aaed1730-ff56-4ccb-a924-66f78ad71267', DEFAULT, '2025-09-22 15:46:38.854621+00', '2025-09-22 15:46:38.854621+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/aaed1730-ff56-4ccb-a924-66f78ad71267/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126', DEFAULT, '2025-09-22 15:46:38.854621+00', '2025-09-22 15:46:38.854621+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/86087992-d92f-48b4-aa56-38ca5b84a27c', DEFAULT, '2025-09-22 15:48:22.477748+00', '2025-09-22 15:48:22.477748+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/86087992-d92f-48b4-aa56-38ca5b84a27c/6bcee3a9-3d3d-4de5-8c41-f5058dfaa126', DEFAULT, '2025-09-22 15:48:22.477748+00', '2025-09-22 15:48:22.477748+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/8d9d474b-c5f6-4aeb-8fec-6686ea3f4cad', DEFAULT, '2025-09-22 15:48:50.905927+00', '2025-09-22 15:48:50.905927+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/8d9d474b-c5f6-4aeb-8fec-6686ea3f4cad/ba293e3e-ce8d-472b-b27e-ea4d96616f3b', DEFAULT, '2025-09-22 15:48:50.905927+00', '2025-09-22 15:48:50.905927+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/7b9b7c9d-681b-4817-883b-683637d8e3f8', DEFAULT, '2025-09-22 15:48:57.675034+00', '2025-09-22 15:48:57.675034+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '90e39f2e-280e-41e4-8237-48f57832d653/7b9b7c9d-681b-4817-883b-683637d8e3f8/ba293e3e-ce8d-472b-b27e-ea4d96616f3b', DEFAULT, '2025-09-22 15:48:57.675034+00', '2025-09-22 15:48:57.675034+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9', DEFAULT, '2025-09-22 15:55:56.308858+00', '2025-09-22 15:55:56.308858+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d', DEFAULT, '2025-09-22 15:55:56.308858+00', '2025-09-22 15:55:56.308858+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/cc5e09ed-8248-4d85-ad83-f0a963b124eb', DEFAULT, '2025-09-22 15:55:56.308858+00', '2025-09-22 15:55:56.308858+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/82eaedc6-0f4b-4448-a616-a402f632116d/499ffbcf-53c1-48cc-9d0d-4332be499dc1', DEFAULT, '2025-09-22 15:55:56.338057+00', '2025-09-22 15:55:56.338057+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2', DEFAULT, '2025-09-22 15:56:22.399377+00', '2025-09-22 15:56:22.399377+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2/499ffbcf-53c1-48cc-9d0d-4332be499dc1', DEFAULT, '2025-09-22 15:56:22.399377+00', '2025-09-22 15:56:22.399377+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/c6574b07-2078-4517-8044-94890328c4d2/cc5e09ed-8248-4d85-ad83-f0a963b124eb', DEFAULT, '2025-09-22 15:56:22.726373+00', '2025-09-22 15:56:22.726373+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'a9a86d4e-8b04-4e46-8190-65dfaf5656e9/completion', DEFAULT, '2025-09-22 15:56:53.193259+00', '2025-09-22 15:56:53.193259+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e', DEFAULT, '2025-09-22 16:05:59.875964+00', '2025-09-22 16:05:59.875964+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e/ffcb84f5-c839-4efe-be8c-40f4888ca3b0', DEFAULT, '2025-09-22 16:05:59.875964+00', '2025-09-22 16:05:59.875964+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', 'fec9cbcc-7d98-4540-be3e-e29b807cf77d/ad9de662-2681-42d3-abfc-18a01dbfbf1e/6f8542b1-7c2a-47be-922f-d8059d9d8a9c', DEFAULT, '2025-09-22 16:06:00.11327+00', '2025-09-22 16:06:00.11327+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/33ae8e85-062b-4bd7-84e2-39f3f0635aae', DEFAULT, '2025-09-22 16:20:02.297901+00', '2025-09-22 16:20:02.297901+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/33ae8e85-062b-4bd7-84e2-39f3f0635aae/95af0801-eabc-4d0a-a90d-c26deed08467', DEFAULT, '2025-09-22 16:20:02.297901+00', '2025-09-22 16:20:02.297901+00');
INSERT INTO storage.prefixes VALUES ('work-proofs', '2ab4011d-7ff1-46ba-be36-c03a73d9f3f6/cancellation', DEFAULT, '2025-09-22 16:20:26.141584+00', '2025-09-22 16:20:26.141584+00');


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 39, true);


--
-- Name: debug_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.debug_log_id_seq', 24, true);


--
-- PostgreSQL database dump complete
--

\unrestrict 11756qqEpMq5OXXaEN5RyhJs8xX5oR0QJudyFmTvaQZoPwgb83Wh9x2qThSriWP

