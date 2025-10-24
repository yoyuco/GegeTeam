drop trigger if exists "tr_auto_initialize_pilot_cycle_on_order_create" on "public"."order_lines";

drop trigger if exists "tr_auto_update_pilot_cycle_on_pause_change" on "public"."order_lines";

drop trigger if exists "tr_pilot_cycle_order_create" on "public"."order_lines";

drop trigger if exists "tr_after_update_order_service_items" on "public"."order_service_items";

drop trigger if exists "on_orders_update" on "public"."orders";

drop trigger if exists "tr_auto_initialize_pilot_cycle_on_first_session" on "public"."work_sessions";

drop trigger if exists "tr_auto_update_pilot_cycle_on_session_end" on "public"."work_sessions";

drop policy "Allow privileged users to read audit logs" on "public"."audit_logs";

drop policy "Allow admin to manage debug logs" on "public"."debug_log";

drop policy "Allow users with permission to add reviews" on "public"."order_reviews";

drop policy "Allow users with permission to view reviews" on "public"."order_reviews";

drop policy "Allow admin to manage permissions" on "public"."permissions";

drop policy "Allow admin to delete" on "public"."role_permissions";

drop policy "Allow admin to insert" on "public"."role_permissions";

drop policy "Allow admin to update" on "public"."role_permissions";

drop policy "Allow managers to resolve reports" on "public"."service_reports";

drop policy "Allow users to read relevant reports" on "public"."service_reports";

drop policy "Allow admins to delete assignments" on "public"."user_role_assignments";

drop policy "Allow admins to insert assignments" on "public"."user_role_assignments";

drop policy "Allow admins to update assignments" on "public"."user_role_assignments";

drop policy "Allow users to read their own, and admins all" on "public"."user_role_assignments";

revoke delete on table "public"."attribute_relationships" from "anon";

revoke insert on table "public"."attribute_relationships" from "anon";

revoke references on table "public"."attribute_relationships" from "anon";

revoke select on table "public"."attribute_relationships" from "anon";

revoke trigger on table "public"."attribute_relationships" from "anon";

revoke truncate on table "public"."attribute_relationships" from "anon";

revoke update on table "public"."attribute_relationships" from "anon";

revoke delete on table "public"."attribute_relationships" from "authenticated";

revoke insert on table "public"."attribute_relationships" from "authenticated";

revoke references on table "public"."attribute_relationships" from "authenticated";

revoke select on table "public"."attribute_relationships" from "authenticated";

revoke trigger on table "public"."attribute_relationships" from "authenticated";

revoke truncate on table "public"."attribute_relationships" from "authenticated";

revoke update on table "public"."attribute_relationships" from "authenticated";

revoke delete on table "public"."attribute_relationships" from "service_role";

revoke insert on table "public"."attribute_relationships" from "service_role";

revoke references on table "public"."attribute_relationships" from "service_role";

revoke select on table "public"."attribute_relationships" from "service_role";

revoke trigger on table "public"."attribute_relationships" from "service_role";

revoke truncate on table "public"."attribute_relationships" from "service_role";

revoke update on table "public"."attribute_relationships" from "service_role";

revoke delete on table "public"."attributes" from "anon";

revoke insert on table "public"."attributes" from "anon";

revoke references on table "public"."attributes" from "anon";

revoke select on table "public"."attributes" from "anon";

revoke trigger on table "public"."attributes" from "anon";

revoke truncate on table "public"."attributes" from "anon";

revoke update on table "public"."attributes" from "anon";

revoke delete on table "public"."attributes" from "authenticated";

revoke insert on table "public"."attributes" from "authenticated";

revoke references on table "public"."attributes" from "authenticated";

revoke select on table "public"."attributes" from "authenticated";

revoke trigger on table "public"."attributes" from "authenticated";

revoke truncate on table "public"."attributes" from "authenticated";

revoke update on table "public"."attributes" from "authenticated";

revoke delete on table "public"."attributes" from "service_role";

revoke insert on table "public"."attributes" from "service_role";

revoke references on table "public"."attributes" from "service_role";

revoke select on table "public"."attributes" from "service_role";

revoke trigger on table "public"."attributes" from "service_role";

revoke truncate on table "public"."attributes" from "service_role";

revoke update on table "public"."attributes" from "service_role";

revoke delete on table "public"."audit_logs" from "anon";

revoke insert on table "public"."audit_logs" from "anon";

revoke references on table "public"."audit_logs" from "anon";

revoke select on table "public"."audit_logs" from "anon";

revoke trigger on table "public"."audit_logs" from "anon";

revoke truncate on table "public"."audit_logs" from "anon";

revoke update on table "public"."audit_logs" from "anon";

revoke delete on table "public"."audit_logs" from "authenticated";

revoke insert on table "public"."audit_logs" from "authenticated";

revoke references on table "public"."audit_logs" from "authenticated";

revoke select on table "public"."audit_logs" from "authenticated";

revoke trigger on table "public"."audit_logs" from "authenticated";

revoke truncate on table "public"."audit_logs" from "authenticated";

revoke update on table "public"."audit_logs" from "authenticated";

revoke delete on table "public"."audit_logs" from "service_role";

revoke insert on table "public"."audit_logs" from "service_role";

revoke references on table "public"."audit_logs" from "service_role";

revoke select on table "public"."audit_logs" from "service_role";

revoke trigger on table "public"."audit_logs" from "service_role";

revoke truncate on table "public"."audit_logs" from "service_role";

revoke update on table "public"."audit_logs" from "service_role";

revoke delete on table "public"."channels" from "anon";

revoke insert on table "public"."channels" from "anon";

revoke references on table "public"."channels" from "anon";

revoke select on table "public"."channels" from "anon";

revoke trigger on table "public"."channels" from "anon";

revoke truncate on table "public"."channels" from "anon";

revoke update on table "public"."channels" from "anon";

revoke delete on table "public"."channels" from "authenticated";

revoke insert on table "public"."channels" from "authenticated";

revoke references on table "public"."channels" from "authenticated";

revoke select on table "public"."channels" from "authenticated";

revoke trigger on table "public"."channels" from "authenticated";

revoke truncate on table "public"."channels" from "authenticated";

revoke update on table "public"."channels" from "authenticated";

revoke delete on table "public"."channels" from "service_role";

revoke insert on table "public"."channels" from "service_role";

revoke references on table "public"."channels" from "service_role";

revoke select on table "public"."channels" from "service_role";

revoke trigger on table "public"."channels" from "service_role";

revoke truncate on table "public"."channels" from "service_role";

revoke update on table "public"."channels" from "service_role";

revoke delete on table "public"."currencies" from "anon";

revoke insert on table "public"."currencies" from "anon";

revoke references on table "public"."currencies" from "anon";

revoke select on table "public"."currencies" from "anon";

revoke trigger on table "public"."currencies" from "anon";

revoke truncate on table "public"."currencies" from "anon";

revoke update on table "public"."currencies" from "anon";

revoke delete on table "public"."currencies" from "authenticated";

revoke insert on table "public"."currencies" from "authenticated";

revoke references on table "public"."currencies" from "authenticated";

revoke select on table "public"."currencies" from "authenticated";

revoke trigger on table "public"."currencies" from "authenticated";

revoke truncate on table "public"."currencies" from "authenticated";

revoke update on table "public"."currencies" from "authenticated";

revoke delete on table "public"."currencies" from "service_role";

revoke insert on table "public"."currencies" from "service_role";

revoke references on table "public"."currencies" from "service_role";

revoke select on table "public"."currencies" from "service_role";

revoke trigger on table "public"."currencies" from "service_role";

revoke truncate on table "public"."currencies" from "service_role";

revoke update on table "public"."currencies" from "service_role";

revoke delete on table "public"."customer_accounts" from "anon";

revoke insert on table "public"."customer_accounts" from "anon";

revoke references on table "public"."customer_accounts" from "anon";

revoke select on table "public"."customer_accounts" from "anon";

revoke trigger on table "public"."customer_accounts" from "anon";

revoke truncate on table "public"."customer_accounts" from "anon";

revoke update on table "public"."customer_accounts" from "anon";

revoke delete on table "public"."customer_accounts" from "authenticated";

revoke insert on table "public"."customer_accounts" from "authenticated";

revoke references on table "public"."customer_accounts" from "authenticated";

revoke select on table "public"."customer_accounts" from "authenticated";

revoke trigger on table "public"."customer_accounts" from "authenticated";

revoke truncate on table "public"."customer_accounts" from "authenticated";

revoke update on table "public"."customer_accounts" from "authenticated";

revoke delete on table "public"."customer_accounts" from "service_role";

revoke insert on table "public"."customer_accounts" from "service_role";

revoke references on table "public"."customer_accounts" from "service_role";

revoke select on table "public"."customer_accounts" from "service_role";

revoke trigger on table "public"."customer_accounts" from "service_role";

revoke truncate on table "public"."customer_accounts" from "service_role";

revoke update on table "public"."customer_accounts" from "service_role";

revoke delete on table "public"."debug_log" from "anon";

revoke insert on table "public"."debug_log" from "anon";

revoke references on table "public"."debug_log" from "anon";

revoke select on table "public"."debug_log" from "anon";

revoke trigger on table "public"."debug_log" from "anon";

revoke truncate on table "public"."debug_log" from "anon";

revoke update on table "public"."debug_log" from "anon";

revoke delete on table "public"."debug_log" from "authenticated";

revoke insert on table "public"."debug_log" from "authenticated";

revoke references on table "public"."debug_log" from "authenticated";

revoke select on table "public"."debug_log" from "authenticated";

revoke trigger on table "public"."debug_log" from "authenticated";

revoke truncate on table "public"."debug_log" from "authenticated";

revoke update on table "public"."debug_log" from "authenticated";

revoke delete on table "public"."debug_log" from "service_role";

revoke insert on table "public"."debug_log" from "service_role";

revoke references on table "public"."debug_log" from "service_role";

revoke select on table "public"."debug_log" from "service_role";

revoke trigger on table "public"."debug_log" from "service_role";

revoke truncate on table "public"."debug_log" from "service_role";

revoke update on table "public"."debug_log" from "service_role";

revoke delete on table "public"."level_exp" from "anon";

revoke insert on table "public"."level_exp" from "anon";

revoke references on table "public"."level_exp" from "anon";

revoke select on table "public"."level_exp" from "anon";

revoke trigger on table "public"."level_exp" from "anon";

revoke truncate on table "public"."level_exp" from "anon";

revoke update on table "public"."level_exp" from "anon";

revoke delete on table "public"."level_exp" from "authenticated";

revoke insert on table "public"."level_exp" from "authenticated";

revoke references on table "public"."level_exp" from "authenticated";

revoke select on table "public"."level_exp" from "authenticated";

revoke trigger on table "public"."level_exp" from "authenticated";

revoke truncate on table "public"."level_exp" from "authenticated";

revoke update on table "public"."level_exp" from "authenticated";

revoke delete on table "public"."level_exp" from "service_role";

revoke insert on table "public"."level_exp" from "service_role";

revoke references on table "public"."level_exp" from "service_role";

revoke select on table "public"."level_exp" from "service_role";

revoke trigger on table "public"."level_exp" from "service_role";

revoke truncate on table "public"."level_exp" from "service_role";

revoke update on table "public"."level_exp" from "service_role";

revoke delete on table "public"."order_lines" from "anon";

revoke insert on table "public"."order_lines" from "anon";

revoke references on table "public"."order_lines" from "anon";

revoke select on table "public"."order_lines" from "anon";

revoke trigger on table "public"."order_lines" from "anon";

revoke truncate on table "public"."order_lines" from "anon";

revoke update on table "public"."order_lines" from "anon";

revoke delete on table "public"."order_lines" from "authenticated";

revoke insert on table "public"."order_lines" from "authenticated";

revoke references on table "public"."order_lines" from "authenticated";

revoke select on table "public"."order_lines" from "authenticated";

revoke trigger on table "public"."order_lines" from "authenticated";

revoke truncate on table "public"."order_lines" from "authenticated";

revoke update on table "public"."order_lines" from "authenticated";

revoke delete on table "public"."order_lines" from "service_role";

revoke insert on table "public"."order_lines" from "service_role";

revoke references on table "public"."order_lines" from "service_role";

revoke select on table "public"."order_lines" from "service_role";

revoke trigger on table "public"."order_lines" from "service_role";

revoke truncate on table "public"."order_lines" from "service_role";

revoke update on table "public"."order_lines" from "service_role";

revoke delete on table "public"."order_reviews" from "anon";

revoke insert on table "public"."order_reviews" from "anon";

revoke references on table "public"."order_reviews" from "anon";

revoke select on table "public"."order_reviews" from "anon";

revoke trigger on table "public"."order_reviews" from "anon";

revoke truncate on table "public"."order_reviews" from "anon";

revoke update on table "public"."order_reviews" from "anon";

revoke delete on table "public"."order_reviews" from "authenticated";

revoke insert on table "public"."order_reviews" from "authenticated";

revoke references on table "public"."order_reviews" from "authenticated";

revoke select on table "public"."order_reviews" from "authenticated";

revoke trigger on table "public"."order_reviews" from "authenticated";

revoke truncate on table "public"."order_reviews" from "authenticated";

revoke update on table "public"."order_reviews" from "authenticated";

revoke delete on table "public"."order_reviews" from "service_role";

revoke insert on table "public"."order_reviews" from "service_role";

revoke references on table "public"."order_reviews" from "service_role";

revoke select on table "public"."order_reviews" from "service_role";

revoke trigger on table "public"."order_reviews" from "service_role";

revoke truncate on table "public"."order_reviews" from "service_role";

revoke update on table "public"."order_reviews" from "service_role";

revoke delete on table "public"."order_service_items" from "anon";

revoke insert on table "public"."order_service_items" from "anon";

revoke references on table "public"."order_service_items" from "anon";

revoke select on table "public"."order_service_items" from "anon";

revoke trigger on table "public"."order_service_items" from "anon";

revoke truncate on table "public"."order_service_items" from "anon";

revoke update on table "public"."order_service_items" from "anon";

revoke delete on table "public"."order_service_items" from "authenticated";

revoke insert on table "public"."order_service_items" from "authenticated";

revoke references on table "public"."order_service_items" from "authenticated";

revoke select on table "public"."order_service_items" from "authenticated";

revoke trigger on table "public"."order_service_items" from "authenticated";

revoke truncate on table "public"."order_service_items" from "authenticated";

revoke update on table "public"."order_service_items" from "authenticated";

revoke delete on table "public"."order_service_items" from "service_role";

revoke insert on table "public"."order_service_items" from "service_role";

revoke references on table "public"."order_service_items" from "service_role";

revoke select on table "public"."order_service_items" from "service_role";

revoke trigger on table "public"."order_service_items" from "service_role";

revoke truncate on table "public"."order_service_items" from "service_role";

revoke update on table "public"."order_service_items" from "service_role";

revoke delete on table "public"."orders" from "anon";

revoke insert on table "public"."orders" from "anon";

revoke references on table "public"."orders" from "anon";

revoke select on table "public"."orders" from "anon";

revoke trigger on table "public"."orders" from "anon";

revoke truncate on table "public"."orders" from "anon";

revoke update on table "public"."orders" from "anon";

revoke delete on table "public"."orders" from "authenticated";

revoke insert on table "public"."orders" from "authenticated";

revoke references on table "public"."orders" from "authenticated";

revoke select on table "public"."orders" from "authenticated";

revoke trigger on table "public"."orders" from "authenticated";

revoke truncate on table "public"."orders" from "authenticated";

revoke update on table "public"."orders" from "authenticated";

revoke delete on table "public"."orders" from "service_role";

revoke insert on table "public"."orders" from "service_role";

revoke references on table "public"."orders" from "service_role";

revoke select on table "public"."orders" from "service_role";

revoke trigger on table "public"."orders" from "service_role";

revoke truncate on table "public"."orders" from "service_role";

revoke update on table "public"."orders" from "service_role";

revoke delete on table "public"."parties" from "anon";

revoke insert on table "public"."parties" from "anon";

revoke references on table "public"."parties" from "anon";

revoke select on table "public"."parties" from "anon";

revoke trigger on table "public"."parties" from "anon";

revoke truncate on table "public"."parties" from "anon";

revoke update on table "public"."parties" from "anon";

revoke delete on table "public"."parties" from "authenticated";

revoke insert on table "public"."parties" from "authenticated";

revoke references on table "public"."parties" from "authenticated";

revoke select on table "public"."parties" from "authenticated";

revoke trigger on table "public"."parties" from "authenticated";

revoke truncate on table "public"."parties" from "authenticated";

revoke update on table "public"."parties" from "authenticated";

revoke delete on table "public"."parties" from "service_role";

revoke insert on table "public"."parties" from "service_role";

revoke references on table "public"."parties" from "service_role";

revoke select on table "public"."parties" from "service_role";

revoke trigger on table "public"."parties" from "service_role";

revoke truncate on table "public"."parties" from "service_role";

revoke update on table "public"."parties" from "service_role";

revoke delete on table "public"."permissions" from "anon";

revoke insert on table "public"."permissions" from "anon";

revoke references on table "public"."permissions" from "anon";

revoke select on table "public"."permissions" from "anon";

revoke trigger on table "public"."permissions" from "anon";

revoke truncate on table "public"."permissions" from "anon";

revoke update on table "public"."permissions" from "anon";

revoke delete on table "public"."permissions" from "authenticated";

revoke insert on table "public"."permissions" from "authenticated";

revoke references on table "public"."permissions" from "authenticated";

revoke select on table "public"."permissions" from "authenticated";

revoke trigger on table "public"."permissions" from "authenticated";

revoke truncate on table "public"."permissions" from "authenticated";

revoke update on table "public"."permissions" from "authenticated";

revoke delete on table "public"."permissions" from "service_role";

revoke insert on table "public"."permissions" from "service_role";

revoke references on table "public"."permissions" from "service_role";

revoke select on table "public"."permissions" from "service_role";

revoke trigger on table "public"."permissions" from "service_role";

revoke truncate on table "public"."permissions" from "service_role";

revoke update on table "public"."permissions" from "service_role";

revoke delete on table "public"."product_variant_attributes" from "anon";

revoke insert on table "public"."product_variant_attributes" from "anon";

revoke references on table "public"."product_variant_attributes" from "anon";

revoke select on table "public"."product_variant_attributes" from "anon";

revoke trigger on table "public"."product_variant_attributes" from "anon";

revoke truncate on table "public"."product_variant_attributes" from "anon";

revoke update on table "public"."product_variant_attributes" from "anon";

revoke delete on table "public"."product_variant_attributes" from "authenticated";

revoke insert on table "public"."product_variant_attributes" from "authenticated";

revoke references on table "public"."product_variant_attributes" from "authenticated";

revoke select on table "public"."product_variant_attributes" from "authenticated";

revoke trigger on table "public"."product_variant_attributes" from "authenticated";

revoke truncate on table "public"."product_variant_attributes" from "authenticated";

revoke update on table "public"."product_variant_attributes" from "authenticated";

revoke delete on table "public"."product_variant_attributes" from "service_role";

revoke insert on table "public"."product_variant_attributes" from "service_role";

revoke references on table "public"."product_variant_attributes" from "service_role";

revoke select on table "public"."product_variant_attributes" from "service_role";

revoke trigger on table "public"."product_variant_attributes" from "service_role";

revoke truncate on table "public"."product_variant_attributes" from "service_role";

revoke update on table "public"."product_variant_attributes" from "service_role";

revoke delete on table "public"."product_variants" from "anon";

revoke insert on table "public"."product_variants" from "anon";

revoke references on table "public"."product_variants" from "anon";

revoke select on table "public"."product_variants" from "anon";

revoke trigger on table "public"."product_variants" from "anon";

revoke truncate on table "public"."product_variants" from "anon";

revoke update on table "public"."product_variants" from "anon";

revoke delete on table "public"."product_variants" from "authenticated";

revoke insert on table "public"."product_variants" from "authenticated";

revoke references on table "public"."product_variants" from "authenticated";

revoke select on table "public"."product_variants" from "authenticated";

revoke trigger on table "public"."product_variants" from "authenticated";

revoke truncate on table "public"."product_variants" from "authenticated";

revoke update on table "public"."product_variants" from "authenticated";

revoke delete on table "public"."product_variants" from "service_role";

revoke insert on table "public"."product_variants" from "service_role";

revoke references on table "public"."product_variants" from "service_role";

revoke select on table "public"."product_variants" from "service_role";

revoke trigger on table "public"."product_variants" from "service_role";

revoke truncate on table "public"."product_variants" from "service_role";

revoke update on table "public"."product_variants" from "service_role";

revoke delete on table "public"."products" from "anon";

revoke insert on table "public"."products" from "anon";

revoke references on table "public"."products" from "anon";

revoke select on table "public"."products" from "anon";

revoke trigger on table "public"."products" from "anon";

revoke truncate on table "public"."products" from "anon";

revoke update on table "public"."products" from "anon";

revoke delete on table "public"."products" from "authenticated";

revoke insert on table "public"."products" from "authenticated";

revoke references on table "public"."products" from "authenticated";

revoke select on table "public"."products" from "authenticated";

revoke trigger on table "public"."products" from "authenticated";

revoke truncate on table "public"."products" from "authenticated";

revoke update on table "public"."products" from "authenticated";

revoke delete on table "public"."products" from "service_role";

revoke insert on table "public"."products" from "service_role";

revoke references on table "public"."products" from "service_role";

revoke select on table "public"."products" from "service_role";

revoke trigger on table "public"."products" from "service_role";

revoke truncate on table "public"."products" from "service_role";

revoke update on table "public"."products" from "service_role";

revoke delete on table "public"."profiles" from "anon";

revoke insert on table "public"."profiles" from "anon";

revoke references on table "public"."profiles" from "anon";

revoke select on table "public"."profiles" from "anon";

revoke trigger on table "public"."profiles" from "anon";

revoke truncate on table "public"."profiles" from "anon";

revoke update on table "public"."profiles" from "anon";

revoke delete on table "public"."profiles" from "authenticated";

revoke insert on table "public"."profiles" from "authenticated";

revoke references on table "public"."profiles" from "authenticated";

revoke select on table "public"."profiles" from "authenticated";

revoke trigger on table "public"."profiles" from "authenticated";

revoke truncate on table "public"."profiles" from "authenticated";

revoke update on table "public"."profiles" from "authenticated";

revoke delete on table "public"."profiles" from "service_role";

revoke insert on table "public"."profiles" from "service_role";

revoke references on table "public"."profiles" from "service_role";

revoke select on table "public"."profiles" from "service_role";

revoke trigger on table "public"."profiles" from "service_role";

revoke truncate on table "public"."profiles" from "service_role";

revoke update on table "public"."profiles" from "service_role";

revoke delete on table "public"."role_permissions" from "anon";

revoke insert on table "public"."role_permissions" from "anon";

revoke references on table "public"."role_permissions" from "anon";

revoke select on table "public"."role_permissions" from "anon";

revoke trigger on table "public"."role_permissions" from "anon";

revoke truncate on table "public"."role_permissions" from "anon";

revoke update on table "public"."role_permissions" from "anon";

revoke delete on table "public"."role_permissions" from "authenticated";

revoke insert on table "public"."role_permissions" from "authenticated";

revoke references on table "public"."role_permissions" from "authenticated";

revoke select on table "public"."role_permissions" from "authenticated";

revoke trigger on table "public"."role_permissions" from "authenticated";

revoke truncate on table "public"."role_permissions" from "authenticated";

revoke update on table "public"."role_permissions" from "authenticated";

revoke delete on table "public"."role_permissions" from "service_role";

revoke insert on table "public"."role_permissions" from "service_role";

revoke references on table "public"."role_permissions" from "service_role";

revoke select on table "public"."role_permissions" from "service_role";

revoke trigger on table "public"."role_permissions" from "service_role";

revoke truncate on table "public"."role_permissions" from "service_role";

revoke update on table "public"."role_permissions" from "service_role";

revoke delete on table "public"."roles" from "anon";

revoke insert on table "public"."roles" from "anon";

revoke references on table "public"."roles" from "anon";

revoke select on table "public"."roles" from "anon";

revoke trigger on table "public"."roles" from "anon";

revoke truncate on table "public"."roles" from "anon";

revoke update on table "public"."roles" from "anon";

revoke delete on table "public"."roles" from "authenticated";

revoke insert on table "public"."roles" from "authenticated";

revoke references on table "public"."roles" from "authenticated";

revoke select on table "public"."roles" from "authenticated";

revoke trigger on table "public"."roles" from "authenticated";

revoke truncate on table "public"."roles" from "authenticated";

revoke update on table "public"."roles" from "authenticated";

revoke delete on table "public"."roles" from "service_role";

revoke insert on table "public"."roles" from "service_role";

revoke references on table "public"."roles" from "service_role";

revoke select on table "public"."roles" from "service_role";

revoke trigger on table "public"."roles" from "service_role";

revoke truncate on table "public"."roles" from "service_role";

revoke update on table "public"."roles" from "service_role";

revoke delete on table "public"."service_reports" from "anon";

revoke insert on table "public"."service_reports" from "anon";

revoke references on table "public"."service_reports" from "anon";

revoke select on table "public"."service_reports" from "anon";

revoke trigger on table "public"."service_reports" from "anon";

revoke truncate on table "public"."service_reports" from "anon";

revoke update on table "public"."service_reports" from "anon";

revoke delete on table "public"."service_reports" from "authenticated";

revoke insert on table "public"."service_reports" from "authenticated";

revoke references on table "public"."service_reports" from "authenticated";

revoke select on table "public"."service_reports" from "authenticated";

revoke trigger on table "public"."service_reports" from "authenticated";

revoke truncate on table "public"."service_reports" from "authenticated";

revoke update on table "public"."service_reports" from "authenticated";

revoke delete on table "public"."service_reports" from "service_role";

revoke insert on table "public"."service_reports" from "service_role";

revoke references on table "public"."service_reports" from "service_role";

revoke select on table "public"."service_reports" from "service_role";

revoke trigger on table "public"."service_reports" from "service_role";

revoke truncate on table "public"."service_reports" from "service_role";

revoke update on table "public"."service_reports" from "service_role";

revoke delete on table "public"."user_role_assignments" from "anon";

revoke insert on table "public"."user_role_assignments" from "anon";

revoke references on table "public"."user_role_assignments" from "anon";

revoke select on table "public"."user_role_assignments" from "anon";

revoke trigger on table "public"."user_role_assignments" from "anon";

revoke truncate on table "public"."user_role_assignments" from "anon";

revoke update on table "public"."user_role_assignments" from "anon";

revoke delete on table "public"."user_role_assignments" from "authenticated";

revoke insert on table "public"."user_role_assignments" from "authenticated";

revoke references on table "public"."user_role_assignments" from "authenticated";

revoke select on table "public"."user_role_assignments" from "authenticated";

revoke trigger on table "public"."user_role_assignments" from "authenticated";

revoke truncate on table "public"."user_role_assignments" from "authenticated";

revoke update on table "public"."user_role_assignments" from "authenticated";

revoke delete on table "public"."user_role_assignments" from "service_role";

revoke insert on table "public"."user_role_assignments" from "service_role";

revoke references on table "public"."user_role_assignments" from "service_role";

revoke select on table "public"."user_role_assignments" from "service_role";

revoke trigger on table "public"."user_role_assignments" from "service_role";

revoke truncate on table "public"."user_role_assignments" from "service_role";

revoke update on table "public"."user_role_assignments" from "service_role";

revoke delete on table "public"."work_session_outputs" from "anon";

revoke insert on table "public"."work_session_outputs" from "anon";

revoke references on table "public"."work_session_outputs" from "anon";

revoke select on table "public"."work_session_outputs" from "anon";

revoke trigger on table "public"."work_session_outputs" from "anon";

revoke truncate on table "public"."work_session_outputs" from "anon";

revoke update on table "public"."work_session_outputs" from "anon";

revoke delete on table "public"."work_session_outputs" from "authenticated";

revoke insert on table "public"."work_session_outputs" from "authenticated";

revoke references on table "public"."work_session_outputs" from "authenticated";

revoke select on table "public"."work_session_outputs" from "authenticated";

revoke trigger on table "public"."work_session_outputs" from "authenticated";

revoke truncate on table "public"."work_session_outputs" from "authenticated";

revoke update on table "public"."work_session_outputs" from "authenticated";

revoke delete on table "public"."work_session_outputs" from "service_role";

revoke insert on table "public"."work_session_outputs" from "service_role";

revoke references on table "public"."work_session_outputs" from "service_role";

revoke select on table "public"."work_session_outputs" from "service_role";

revoke trigger on table "public"."work_session_outputs" from "service_role";

revoke truncate on table "public"."work_session_outputs" from "service_role";

revoke update on table "public"."work_session_outputs" from "service_role";

revoke delete on table "public"."work_sessions" from "anon";

revoke insert on table "public"."work_sessions" from "anon";

revoke references on table "public"."work_sessions" from "anon";

revoke select on table "public"."work_sessions" from "anon";

revoke trigger on table "public"."work_sessions" from "anon";

revoke truncate on table "public"."work_sessions" from "anon";

revoke update on table "public"."work_sessions" from "anon";

revoke delete on table "public"."work_sessions" from "authenticated";

revoke insert on table "public"."work_sessions" from "authenticated";

revoke references on table "public"."work_sessions" from "authenticated";

revoke select on table "public"."work_sessions" from "authenticated";

revoke trigger on table "public"."work_sessions" from "authenticated";

revoke truncate on table "public"."work_sessions" from "authenticated";

revoke update on table "public"."work_sessions" from "authenticated";

revoke delete on table "public"."work_sessions" from "service_role";

revoke insert on table "public"."work_sessions" from "service_role";

revoke references on table "public"."work_sessions" from "service_role";

revoke select on table "public"."work_sessions" from "service_role";

revoke trigger on table "public"."work_sessions" from "service_role";

revoke truncate on table "public"."work_sessions" from "service_role";

revoke update on table "public"."work_sessions" from "service_role";

alter table "public"."attribute_relationships" drop constraint "attribute_relationships_child_attribute_id_fkey";

alter table "public"."attribute_relationships" drop constraint "attribute_relationships_parent_attribute_id_fkey";

alter table "public"."customer_accounts" drop constraint "customer_accounts_party_id_fkey";

alter table "public"."order_lines" drop constraint "order_lines_customer_account_id_fkey";

alter table "public"."order_lines" drop constraint "order_lines_order_id_fkey";

alter table "public"."order_lines" drop constraint "order_lines_variant_id_fkey";

alter table "public"."order_reviews" drop constraint "order_reviews_created_by_fkey";

alter table "public"."order_reviews" drop constraint "order_reviews_order_line_id_fkey";

alter table "public"."order_service_items" drop constraint "fk_service_kind";

alter table "public"."order_service_items" drop constraint "order_service_items_order_line_id_fkey";

alter table "public"."orders" drop constraint "orders_channel_id_fkey";

alter table "public"."orders" drop constraint "orders_created_by_fkey";

alter table "public"."orders" drop constraint "orders_currency_id_fkey";

alter table "public"."orders" drop constraint "orders_party_id_fkey";

alter table "public"."product_variant_attributes" drop constraint "product_variant_attributes_attribute_id_fkey";

alter table "public"."product_variant_attributes" drop constraint "product_variant_attributes_variant_id_fkey";

alter table "public"."product_variants" drop constraint "product_variants_product_id_fkey";

alter table "public"."role_permissions" drop constraint "role_permissions_permission_id_fkey";

alter table "public"."role_permissions" drop constraint "role_permissions_role_id_fkey";

alter table "public"."service_reports" drop constraint "service_reports_order_line_id_fkey";

alter table "public"."service_reports" drop constraint "service_reports_order_service_item_id_fkey";

alter table "public"."service_reports" drop constraint "service_reports_reported_by_fkey";

alter table "public"."service_reports" drop constraint "service_reports_resolved_by_fkey";

alter table "public"."user_role_assignments" drop constraint "user_role_assignments_business_area_attribute_id_fkey";

alter table "public"."user_role_assignments" drop constraint "user_role_assignments_game_attribute_id_fkey";

alter table "public"."user_role_assignments" drop constraint "user_role_assignments_role_id_fkey1";

alter table "public"."user_role_assignments" drop constraint "user_role_assignments_user_id_fkey1";

alter table "public"."work_session_outputs" drop constraint "work_session_outputs_order_service_item_id_fkey";

alter table "public"."work_session_outputs" drop constraint "work_session_outputs_work_session_id_fkey";

alter table "public"."work_sessions" drop constraint "work_sessions_farmer_id_fkey";

alter table "public"."work_sessions" drop constraint "work_sessions_order_line_id_fkey";

drop function if exists "public"."get_boosting_orders_v2"();

alter table "public"."debug_log" alter column "id" set default nextval('public.debug_log_id_seq'::regclass);

alter table "public"."orders" alter column "side" set default 'SELL'::public.order_side_enum;

alter table "public"."orders" alter column "side" set data type public.order_side_enum using "side"::text::public.order_side_enum;

alter table "public"."products" alter column "type" set data type public.product_type_enum using "type"::text::public.product_type_enum;

alter table "public"."profiles" alter column "created_at" set default timezone('utc'::text, now());

alter table "public"."profiles" alter column "updated_at" set default timezone('utc'::text, now());

alter table "public"."roles" alter column "code" set data type public.app_role using "code"::text::public.app_role;

alter table "public"."attribute_relationships" add constraint "attribute_relationships_child_attribute_id_fkey" FOREIGN KEY (child_attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE not valid;

alter table "public"."attribute_relationships" validate constraint "attribute_relationships_child_attribute_id_fkey";

alter table "public"."attribute_relationships" add constraint "attribute_relationships_parent_attribute_id_fkey" FOREIGN KEY (parent_attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE not valid;

alter table "public"."attribute_relationships" validate constraint "attribute_relationships_parent_attribute_id_fkey";

alter table "public"."customer_accounts" add constraint "customer_accounts_party_id_fkey" FOREIGN KEY (party_id) REFERENCES public.parties(id) not valid;

alter table "public"."customer_accounts" validate constraint "customer_accounts_party_id_fkey";

alter table "public"."order_lines" add constraint "order_lines_customer_account_id_fkey" FOREIGN KEY (customer_account_id) REFERENCES public.customer_accounts(id) not valid;

alter table "public"."order_lines" validate constraint "order_lines_customer_account_id_fkey";

alter table "public"."order_lines" add constraint "order_lines_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE not valid;

alter table "public"."order_lines" validate constraint "order_lines_order_id_fkey";

alter table "public"."order_lines" add constraint "order_lines_variant_id_fkey" FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) not valid;

alter table "public"."order_lines" validate constraint "order_lines_variant_id_fkey";

alter table "public"."order_reviews" add constraint "order_reviews_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."order_reviews" validate constraint "order_reviews_created_by_fkey";

alter table "public"."order_reviews" add constraint "order_reviews_order_line_id_fkey" FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id) ON DELETE CASCADE not valid;

alter table "public"."order_reviews" validate constraint "order_reviews_order_line_id_fkey";

alter table "public"."order_service_items" add constraint "fk_service_kind" FOREIGN KEY (service_kind_id) REFERENCES public.attributes(id) not valid;

alter table "public"."order_service_items" validate constraint "fk_service_kind";

alter table "public"."order_service_items" add constraint "order_service_items_order_line_id_fkey" FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id) ON DELETE CASCADE not valid;

alter table "public"."order_service_items" validate constraint "order_service_items_order_line_id_fkey";

alter table "public"."orders" add constraint "orders_channel_id_fkey" FOREIGN KEY (channel_id) REFERENCES public.channels(id) not valid;

alter table "public"."orders" validate constraint "orders_channel_id_fkey";

alter table "public"."orders" add constraint "orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."orders" validate constraint "orders_created_by_fkey";

alter table "public"."orders" add constraint "orders_currency_id_fkey" FOREIGN KEY (currency_id) REFERENCES public.currencies(id) not valid;

alter table "public"."orders" validate constraint "orders_currency_id_fkey";

alter table "public"."orders" add constraint "orders_party_id_fkey" FOREIGN KEY (party_id) REFERENCES public.parties(id) not valid;

alter table "public"."orders" validate constraint "orders_party_id_fkey";

alter table "public"."product_variant_attributes" add constraint "product_variant_attributes_attribute_id_fkey" FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE not valid;

alter table "public"."product_variant_attributes" validate constraint "product_variant_attributes_attribute_id_fkey";

alter table "public"."product_variant_attributes" add constraint "product_variant_attributes_variant_id_fkey" FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) ON DELETE CASCADE not valid;

alter table "public"."product_variant_attributes" validate constraint "product_variant_attributes_variant_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) not valid;

alter table "public"."product_variants" validate constraint "product_variants_product_id_fkey";

alter table "public"."role_permissions" add constraint "role_permissions_permission_id_fkey" FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_permission_id_fkey";

alter table "public"."role_permissions" add constraint "role_permissions_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_role_id_fkey";

alter table "public"."service_reports" add constraint "service_reports_order_line_id_fkey" FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id) not valid;

alter table "public"."service_reports" validate constraint "service_reports_order_line_id_fkey";

alter table "public"."service_reports" add constraint "service_reports_order_service_item_id_fkey" FOREIGN KEY (order_service_item_id) REFERENCES public.order_service_items(id) not valid;

alter table "public"."service_reports" validate constraint "service_reports_order_service_item_id_fkey";

alter table "public"."service_reports" add constraint "service_reports_reported_by_fkey" FOREIGN KEY (reported_by) REFERENCES public.profiles(id) not valid;

alter table "public"."service_reports" validate constraint "service_reports_reported_by_fkey";

alter table "public"."service_reports" add constraint "service_reports_resolved_by_fkey" FOREIGN KEY (resolved_by) REFERENCES public.profiles(id) not valid;

alter table "public"."service_reports" validate constraint "service_reports_resolved_by_fkey";

alter table "public"."user_role_assignments" add constraint "user_role_assignments_business_area_attribute_id_fkey" FOREIGN KEY (business_area_attribute_id) REFERENCES public.attributes(id) ON DELETE SET NULL not valid;

alter table "public"."user_role_assignments" validate constraint "user_role_assignments_business_area_attribute_id_fkey";

alter table "public"."user_role_assignments" add constraint "user_role_assignments_game_attribute_id_fkey" FOREIGN KEY (game_attribute_id) REFERENCES public.attributes(id) ON DELETE SET NULL not valid;

alter table "public"."user_role_assignments" validate constraint "user_role_assignments_game_attribute_id_fkey";

alter table "public"."user_role_assignments" add constraint "user_role_assignments_role_id_fkey1" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."user_role_assignments" validate constraint "user_role_assignments_role_id_fkey1";

alter table "public"."user_role_assignments" add constraint "user_role_assignments_user_id_fkey1" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."user_role_assignments" validate constraint "user_role_assignments_user_id_fkey1";

alter table "public"."work_session_outputs" add constraint "work_session_outputs_order_service_item_id_fkey" FOREIGN KEY (order_service_item_id) REFERENCES public.order_service_items(id) not valid;

alter table "public"."work_session_outputs" validate constraint "work_session_outputs_order_service_item_id_fkey";

alter table "public"."work_session_outputs" add constraint "work_session_outputs_work_session_id_fkey" FOREIGN KEY (work_session_id) REFERENCES public.work_sessions(id) ON DELETE CASCADE not valid;

alter table "public"."work_session_outputs" validate constraint "work_session_outputs_work_session_id_fkey";

alter table "public"."work_sessions" add constraint "work_sessions_farmer_id_fkey" FOREIGN KEY (farmer_id) REFERENCES public.profiles(id) not valid;

alter table "public"."work_sessions" validate constraint "work_sessions_farmer_id_fkey";

alter table "public"."work_sessions" add constraint "work_sessions_order_line_id_fkey" FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id) not valid;

alter table "public"."work_sessions" validate constraint "work_sessions_order_line_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.can_assign_pilot_order(p_order_id uuid)
 RETURNS TABLE(can_assign boolean, reason text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_pilot_is_blocked BOOLEAN;
    v_pilot_warning_level INTEGER;
BEGIN
    -- Lấy thông tin order
    SELECT
        (SELECT a.name FROM product_variant_attributes pva
         JOIN attributes a ON pva.attribute_id = a.id
         WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type,
        o.status,
        ol.pilot_is_blocked,
        ol.pilot_warning_level
    INTO v_service_type, v_order_status, v_pilot_is_blocked, v_pilot_warning_level
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE o.id = p_order_id;

    -- Chỉ áp dụng cho pilot orders đang hoạt động
    IF v_service_type != 'pilot' OR
       v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN QUERY SELECT true, 'Không áp dụng cho đơn hàng này'::TEXT;
        RETURN;
    END IF;

    -- Kiểm tra blocked status
    IF v_pilot_is_blocked THEN
        RETURN QUERY SELECT false, 'Pilot đã online liên tục quá 6 ngày, cần nghỉ để reset chu kỳ'::TEXT;
        RETURN;
    END IF;

    -- Kiểm tra warning level
    IF v_pilot_warning_level >= 1 THEN
        RETURN QUERY SELECT true, 'Cảnh báo: Pilot sắp đạt giới hạn online liên tục'::TEXT;
        RETURN;
    END IF;

    -- Có thể gán
    RETURN QUERY SELECT true, 'Có thể gán đơn hàng cho pilot'::TEXT;
    RETURN;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.manual_reset_pilot_cycle(p_order_line_id uuid)
 RETURNS TABLE(success boolean, message text, old_warning_level integer, new_warning_level integer, old_is_blocked boolean, new_is_blocked boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_old_warning_level INTEGER;
    v_old_is_blocked BOOLEAN;
    v_new_warning_level INTEGER;
    v_new_is_blocked BOOLEAN;
BEGIN
    -- Get old values
    SELECT pilot_warning_level, pilot_is_blocked
    INTO v_old_warning_level, v_old_is_blocked
    FROM order_lines
    WHERE id = p_order_line_id;

    -- Force reset by resetting paused_at and recalculating
    UPDATE order_lines
    SET
        paused_at = NOW(),
        pilot_warning_level = 0,
        pilot_is_blocked = FALSE
    WHERE id = p_order_line_id;

    -- Get new values
    SELECT pilot_warning_level, pilot_is_blocked
    INTO v_new_warning_level, v_new_is_blocked
    FROM order_lines
    WHERE id = p_order_line_id;

    RETURN QUERY SELECT
        TRUE,
        'Pilot cycle reset successfully',
        v_old_warning_level,
        v_new_warning_level,
        v_old_is_blocked,
        v_new_is_blocked;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.reset_eligible_pilot_cycles()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    line_record RECORD;
    hours_online NUMERIC;
    hours_rest NUMERIC;
    required_rest_hours INTEGER;
BEGIN
    -- Lặp qua tất cả các đơn hàng pilot đang trong trạng thái nghỉ
    FOR line_record IN
        SELECT 
            ol.id, 
            ol.paused_at,
            COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
        FROM order_lines ol
        JOIN orders o ON ol.order_id = o.id
        JOIN product_variants pv ON ol.variant_id = pv.id
        WHERE 
            pv.display_name = 'Service - Pilot'
            AND ol.paused_at IS NOT NULL
            -- <<< THÊM ĐIỀU KIỆN LỌC MỚI Ở ĐÂY >>>
            AND o.status <> 'customer_playing' 
            AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    LOOP
        -- Phần logic tính toán còn lại giữ nguyên
        hours_online := EXTRACT(EPOCH FROM (line_record.paused_at - line_record.cycle_start_at)) / 3600;
        hours_rest := EXTRACT(EPOCH FROM (NOW() - line_record.paused_at)) / 3600;

        required_rest_hours := CASE
            WHEN hours_online <= 4 * 24 THEN 6
            ELSE 12
        END;

        IF hours_rest >= required_rest_hours THEN
            UPDATE order_lines
            SET
                pilot_cycle_start_at = line_record.paused_at,
                pilot_warning_level = 0,
                pilot_is_blocked = FALSE,
                paused_at = NULL
            WHERE id = line_record.id;
        END IF;
    END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.reset_pilot_cycle_on_completion(p_order_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Reset warning levels khi đơn hoàn thành/hủy
    UPDATE order_lines
    SET
        pilot_warning_level = 0,
        pilot_is_blocked = FALSE,
        updated_at = now()
    WHERE order_id = p_order_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_auto_update_pilot_cycle_on_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    line_record RECORD;
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM orders o
        JOIN order_lines ol ON o.id = ol.order_id
        JOIN product_variants pv ON ol.variant_id = pv.id
        WHERE o.id = NEW.id
        AND pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update all pilot lines for this order
        FOR line_record IN
            SELECT ol.id FROM order_lines ol
            WHERE ol.order_id = NEW.id
        LOOP
            PERFORM public.update_pilot_cycle_warning(line_record.id);
            PERFORM public.check_and_reset_pilot_cycle(line_record.id);
        END LOOP;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_vault_secret(p_name text, p_secret text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    INSERT INTO vault.secrets (name, secret)
    VALUES (p_name, p_secret);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.admin_get_all_users()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    IF NOT has_permission('admin:manage_roles') THEN RAISE EXCEPTION 'Authorization failed.'; END IF;
    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'id', p.id, -- Đây là profile_id
            'display_name', p.display_name, 
            'status', p.status, 
            'email', u.email, 
            'assignments', COALESCE(asg.assignments, '[]'::jsonb)
        ))
        FROM auth.users u
        JOIN public.profiles p ON u.id = p.auth_id
        LEFT JOIN (
            SELECT
                ura.user_id,
                jsonb_agg(jsonb_build_object(
                    'assignment_id', ura.id, 
                    'role_id', ura.role_id, 
                    'role_code', r.code, 
                    'role_name', r.name,
                    'game_attribute_id', ura.game_attribute_id, 
                    'game_code', game_attr.code, 
                    'game_name', game_attr.name,
                    'business_area_attribute_id', ura.business_area_attribute_id, 
                    'business_area_code', area_attr.code, 
                    'business_area_name', area_attr.name
                )) as assignments
            FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
            LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
            GROUP BY ura.user_id
        ) asg ON p.id = asg.user_id -- <<< SỬA LỖI Ở ĐÂY (từ u.id thành p.id)
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.admin_get_roles_and_permissions()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  -- Chỉ người có quyền mới được thực thi
  IF NOT has_permission('admin:manage_roles') THEN
    RAISE EXCEPTION 'Authorization failed.';
  END IF;

  RETURN jsonb_build_object(
    'roles', (SELECT jsonb_agg(r) FROM (SELECT id, name, code FROM roles ORDER BY name) r),
    -- SỬA ĐỔI: Thêm cột `description_vi` vào câu SELECT
    'permissions', (SELECT jsonb_agg(p) FROM (SELECT id, code, description, "group", description_vi FROM permissions ORDER BY "group", code) p),
    'assignments', (SELECT jsonb_agg(rp) FROM (SELECT role_id, permission_id FROM role_permissions) rp)
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.admin_rebase_item_progress_v1(p_service_item_id uuid, p_authoritative_done_qty numeric, p_new_params jsonb, p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    last_session_id uuid;
BEGIN
    -- 1. Kiểm tra quyền hạn
    IF NOT has_permission('reports:resolve') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- 2. Đánh dấu tất cả các output cũ của item này là lỗi thời (obsolete)
    UPDATE public.work_session_outputs
    SET is_obsolete = TRUE
    WHERE order_service_item_id = p_service_item_id;

    -- 3. Tìm session ID cuối cùng để gắn bản ghi "chuẩn hóa" vào cho có ngữ cảnh
    SELECT work_session_id INTO last_session_id
    FROM public.work_session_outputs
    WHERE order_service_item_id = p_service_item_id
    ORDER BY id DESC
    LIMIT 1;

    -- 4. Tạo một bản ghi output "chuẩn" duy nhất, ghi đè lên tất cả lịch sử cũ
    INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, start_value, delta, params)
    VALUES (
        last_session_id,
        p_service_item_id,
        0,
        p_authoritative_done_qty,
        jsonb_build_object(
            'correction_reason', p_reason,
            'corrected_by', auth.uid(),
            'corrected_at', now()
        )
    );

    -- 5. Cập nhật lại hạng mục dịch vụ với done_qty và params chuẩn
    UPDATE public.order_service_items
    SET 
        done_qty = p_authoritative_done_qty,
        params = p_new_params
    WHERE id = p_service_item_id;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.admin_update_permissions_for_role(p_role_id uuid, p_permission_ids uuid[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_permission_id uuid;
BEGIN
  -- Chỉ người có quyền mới được thực thi
  IF NOT has_permission('admin:manage_roles') THEN
    RAISE EXCEPTION 'Authorization failed.';
  END IF;
  
  -- Xóa tất cả các quyền cũ của role này
  DELETE FROM public.role_permissions WHERE role_id = p_role_id;
  
  -- Thêm lại các quyền mới từ danh sách được cung cấp
  IF array_length(p_permission_ids, 1) > 0 THEN
    FOREACH v_permission_id IN ARRAY p_permission_ids
    LOOP
      INSERT INTO public.role_permissions (role_id, permission_id)
      VALUES (p_role_id, v_permission_id);
    END LOOP;
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.admin_update_user_assignments(p_user_id uuid, p_assignments jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    IF NOT has_permission('admin:manage_roles') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Xóa tất cả các gán quyền cũ của người dùng này
    DELETE FROM public.user_role_assignments WHERE user_id = p_user_id;

    -- Thêm các gán quyền mới từ payload
    IF jsonb_array_length(p_assignments) > 0 THEN
        INSERT INTO public.user_role_assignments (user_id, role_id, game_attribute_id, business_area_attribute_id)
        SELECT
            p_user_id,
            (a->>'role_id')::uuid,
            (a->>'game_attribute_id')::uuid,
            (a->>'business_area_attribute_id')::uuid
        FROM jsonb_array_elements(p_assignments) a;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.admin_update_user_status(p_user_id uuid, p_new_status text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Chỉ người có quyền mới được thực hiện
    IF NOT has_permission('admin:manage_roles') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Cập nhật trạng thái trong bảng profiles
    UPDATE public.profiles
    SET status = p_new_status
    WHERE id = p_user_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.audit_ctx_v1()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select jsonb_strip_nulls(jsonb_build_object(
  'role', current_setting('role', true),
  'sub',  nullif(current_setting('request.jwt.claim.sub',  true), ''),
  'email',nullif(current_setting('request.jwt.claim.email',true), ''),
  'aud',  nullif(current_setting('request.jwt.claim.aud',  true), '')
));
$function$
;

CREATE OR REPLACE FUNCTION public.audit_diff_v1(old_row jsonb, new_row jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public'
AS $function$
DECLARE result jsonb := '{}'::jsonb; rec record;
BEGIN
    IF old_row IS NULL THEN -- INSERT
        FOR rec IN SELECT key, value FROM jsonb_each(new_row) LOOP result := result || jsonb_build_object(rec.key, jsonb_build_object('new', rec.value)); END LOOP;
        RETURN result;
    END IF;
    IF new_row IS NULL THEN -- DELETE
        FOR rec IN SELECT key, value FROM jsonb_each(old_row) LOOP result := result || jsonb_build_object(rec.key, jsonb_build_object('old', rec.value)); END LOOP;
        RETURN result;
    END IF;
    -- UPDATE
    FOR rec IN SELECT key, value FROM jsonb_each(new_row) LOOP
        IF old_row->rec.key IS NULL OR old_row->rec.key <> rec.value THEN
            result := result || jsonb_build_object(rec.key, jsonb_build_object('old', old_row->rec.key, 'new', rec.value));
        END IF;
    END LOOP;
    RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cancel_order_line_v1(p_line_id uuid, p_cancellation_proof_urls text[], p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  target_order_id uuid;
  v_context jsonb;
  v_current_status text;
BEGIN
  -- Bước 1: Lấy order_id, status và ngữ cảnh từ order_line_id
  SELECT
    ol.order_id,
    o.status,
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO
    target_order_id,
    v_current_status,
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  IF target_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- Bước 2: Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:cancel', v_context) THEN
    RAISE EXCEPTION 'User does not have permission to cancel orders';
  END IF;

  -- Bước 3: Dừng deadline nếu đang in_progress
  IF v_current_status = 'in_progress' THEN
    UPDATE public.order_lines
    SET paused_at = NOW()
    WHERE id = p_line_id;
  END IF;

  -- Bước 4: Cập nhật trạng thái và lưu bằng chứng
  UPDATE public.orders
  SET
    status = 'cancelled',
    notes = p_reason
  WHERE id = target_order_id;

  UPDATE public.order_lines
  SET
    action_proof_urls = p_cancellation_proof_urls
  WHERE id = p_line_id;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.cancel_work_session_v1(p_session_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_session public.work_sessions%ROWTYPE;
    v_order_line_id UUID;
    v_order_id UUID;
    v_service_type TEXT;
    completed_sessions_count INT;
    v_context jsonb;
BEGIN
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RETURN; END IF;

    -- Lấy ngữ cảnh để kiểm tra quyền override
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    v_order_line_id := v_session.order_line_id;

    -- ✅ FIX: Lấy service_type từ attributes (đồng bộ với toggle_customer_playing)
    SELECT
        ol.order_id,
        (SELECT a.name FROM product_variant_attributes pva
         JOIN attributes a ON pva.attribute_id = a.id
         WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type
    INTO
        v_order_id,
        v_service_type
    FROM public.order_lines ol
    WHERE ol.id = v_order_line_id;

    -- ✅ FIX: Dùng tên đúng - kiểm tra cả 2 khả năng
    IF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
        -- Hoàn lại deadline nếu đã cộng khi start
        IF v_session.unpaused_duration IS NOT NULL THEN
            UPDATE public.order_lines
            SET
                deadline_to = deadline_to - v_session.unpaused_duration,
                total_paused_duration = total_paused_duration - v_session.unpaused_duration
            WHERE id = v_order_line_id;
        END IF;

        -- Luôn set paused_at khi cancel session (để bảo toàn deadline)
        UPDATE public.order_lines
        SET paused_at = NOW()
        WHERE id = v_order_line_id;
    END IF;

    DELETE FROM public.work_sessions WHERE id = p_session_id;

    SELECT count(*) INTO completed_sessions_count
    FROM public.work_sessions
    WHERE order_line_id = v_order_line_id AND ended_at IS NOT NULL;

    IF completed_sessions_count > 0 THEN
        IF v_service_type IN ('Service - Pilot', 'Pilot') THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    ELSE
        UPDATE public.orders SET status = 'new' WHERE id = v_order_id;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_and_reset_pilot_cycle(p_order_line_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_hours_online NUMERIC;
    v_hours_rest NUMERIC;
    v_current_paused_at TIMESTAMP WITH TIME ZONE;
    v_cycle_start_at TIMESTAMP WITH TIME ZONE;
    v_required_rest_hours INTEGER;
BEGIN
    -- Get order information
    SELECT pv.display_name, o.status, ol.paused_at,
           COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
    INTO v_service_type, v_order_status, v_current_paused_at, v_cycle_start_at
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
    JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Check if currently resting
    IF v_current_paused_at IS NULL THEN
        RETURN;
    END IF;

    -- Calculate online and rest hours
    v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    v_hours_rest := EXTRACT(EPOCH FROM (NOW() - v_current_paused_at)) / 3600;

    -- Determine required rest hours
    v_required_rest_hours := CASE
        WHEN v_hours_online <= 4 * 24 THEN 6  -- <= 4 days: 6 hours
        ELSE 12  -- > 4 days: 12 hours
    END;

    -- Reset if enough rest
    IF v_hours_rest >= v_required_rest_hours THEN
        -- Reset pilot cycle
        UPDATE public.order_lines
        SET
            pilot_cycle_start_at = v_current_paused_at,
            pilot_warning_level = 0,
            pilot_is_blocked = FALSE,
            paused_at = NULL
        WHERE id = p_order_line_id;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.complete_order_line_v1(p_line_id uuid, p_completion_proof_urls text[], p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  target_order_id uuid;
  v_context jsonb;
  v_current_status text;
BEGIN
  -- Bước 1: Lấy order_id, status và ngữ cảnh từ p_line_id
  SELECT
    ol.order_id,
    o.status,
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO
    target_order_id,
    v_current_status,
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  IF target_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- Bước 2: Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:complete', v_context) THEN
    RAISE EXCEPTION 'User does not have permission to complete orders';
  END IF;

  -- Bước 3: Dừng deadline nếu đang in_progress
  IF v_current_status = 'in_progress' THEN
    UPDATE public.order_lines
    SET paused_at = NOW()
    WHERE id = p_line_id;
  END IF;

  -- Bước 4: Cập nhật trạng thái và lưu bằng chứng
  UPDATE public.orders
  SET
    status = 'completed',
    notes = p_reason
  WHERE id = target_order_id;

  UPDATE public.order_lines
  SET
    action_proof_urls = p_completion_proof_urls
  WHERE id = p_line_id;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_service_order_v1(p_channel_code text, p_service_type text, p_customer_name text, p_deadline timestamp with time zone, p_price numeric, p_currency_code text, p_package_type text, p_package_note text, p_customer_account_id uuid, p_new_account_details jsonb, p_game_code text, p_service_items jsonb)
 RETURNS TABLE(order_id uuid, line_id uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_party_id uuid;
    v_channel_id uuid;
    v_currency_id uuid;
    v_product_id uuid;
    v_variant_id uuid;
    v_new_order_id uuid;
    v_new_line_id uuid;
    v_account_id uuid;
    v_service_type_attr_id uuid;
    v_variant_name text;
    item RECORD;
BEGIN
    -- 1. Kiểm tra quyền hạn
    -- FIX #3: Changed 'order:create' to 'orders:create'
    IF NOT has_permission('orders:create', jsonb_build_object('game_code', p_game_code, 'business_area_code', 'SERVICE')) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- 2. Tìm hoặc tạo Party (khách hàng)
    SELECT id INTO v_party_id FROM public.parties WHERE name = p_customer_name AND type = 'customer';
    IF v_party_id IS NULL THEN
        INSERT INTO public.parties (name, type) VALUES (p_customer_name, 'customer') RETURNING id INTO v_party_id;
    END IF;

    -- 3. Tìm hoặc tạo Channel (kênh bán)
    SELECT id INTO v_channel_id FROM public.channels WHERE code = p_channel_code;
    IF v_channel_id IS NULL THEN
        INSERT INTO public.channels (code) VALUES (p_channel_code) RETURNING id INTO v_channel_id;
    END IF;

    -- 4. Tìm hoặc tạo Currency
    SELECT id INTO v_currency_id FROM public.currencies WHERE code = p_currency_code;
    IF v_currency_id IS NULL THEN
        INSERT INTO public.currencies (code, name) VALUES (p_currency_code, p_currency_code) RETURNING id INTO v_currency_id;
    END IF;

    -- 5. Xử lý tài khoản khách hàng
    IF p_customer_account_id IS NOT NULL THEN
        v_account_id := p_customer_account_id;
    ELSIF p_new_account_details IS NOT NULL AND jsonb_typeof(p_new_account_details) = 'object' THEN
        INSERT INTO public.customer_accounts (party_id, account_type, label, btag, login_id, login_pwd)
        VALUES (v_party_id, p_new_account_details->>'account_type', p_new_account_details->>'label', p_new_account_details->>'btag', p_new_account_details->>'login_id', p_new_account_details->>'login_pwd')
        RETURNING id INTO v_account_id;
    END IF;

    -- 6. Tìm hoặc Tạo (Upsert) Product Variant chuẩn
    -- FIX #1: Changed variant names to 'Service - Selfplay' and 'Service - Pilot' (with space)
    -- FIX #2: Use LOWER() for case-insensitive check
    IF LOWER(p_service_type) = 'selfplay' THEN
        v_variant_name := 'Service - Selfplay';
    ELSE
        v_variant_name := 'Service - Pilot';
    END IF;

    SELECT id INTO v_product_id FROM public.products WHERE type = 'SERVICE' LIMIT 1;
    IF v_product_id IS NULL THEN
        RAISE EXCEPTION 'Product with type SERVICE not found.';
    END IF;

    INSERT INTO public.product_variants (product_id, display_name, price)
    VALUES (v_product_id, v_variant_name, 0)
    ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
    RETURNING id INTO v_variant_id;

    -- FIX #2: Changed 'SELFPAY' to 'SELFPLAY'
    SELECT id INTO v_service_type_attr_id FROM public.attributes WHERE type = 'SERVICE_TYPE' AND code = (CASE WHEN LOWER(p_service_type) = 'selfplay' THEN 'SELFPLAY' ELSE 'PILOT' END);
    IF v_service_type_attr_id IS NOT NULL THEN
        INSERT INTO public.product_variant_attributes (variant_id, attribute_id)
        VALUES (v_variant_id, v_service_type_attr_id)
        ON CONFLICT DO NOTHING;
    END IF;

    -- 7. Tạo Order và Order Line
    INSERT INTO public.orders (party_id, channel_id, currency_id, price_total, created_by, game_code, package_type, package_note, status)
    VALUES (v_party_id, v_channel_id, v_currency_id, p_price, public.get_current_profile_id(), p_game_code, p_package_type, p_package_note, 'new')
    RETURNING id INTO v_new_order_id;

    INSERT INTO public.order_lines (order_id, variant_id, customer_account_id, qty, unit_price, deadline_to)
    VALUES (v_new_order_id, v_variant_id, v_account_id, 1, p_price, p_deadline)
    RETURNING id INTO v_new_line_id;

    -- 8. Chèn các hạng mục dịch vụ (Service Items) - KEEP ORIGINAL LOGIC
    IF p_service_items IS NOT NULL AND jsonb_typeof(p_service_items) = 'array' THEN
        FOR item IN SELECT * FROM jsonb_array_elements(p_service_items) LOOP
            INSERT INTO public.order_service_items (order_line_id, service_kind_id, params, plan_qty)
            VALUES (v_new_line_id, (item.value->>'service_kind_id')::uuid, (item.value->'params')::jsonb, (item.value->>'plan_qty')::numeric);
        END LOOP;
    END IF;

    -- 9. Trả về ID
    RETURN QUERY SELECT v_new_order_id, v_new_line_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_service_report_v1(p_order_service_item_id uuid, p_description text, p_proof_urls text[])
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$DECLARE
    v_order_line_id uuid;
    new_report_id uuid;
    v_context jsonb;
BEGIN
    -- Lấy ngữ cảnh để kiểm tra quyền
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_service_items osi
    JOIN public.order_lines ol ON osi.order_line_id = ol.id
    JOIN public.orders o ON ol.order_id = o.id
    WHERE osi.id = p_order_service_item_id;

    -- SỬA LỖI: Thêm kiểm tra quyền tường minh ở đầu hàm
    IF NOT has_permission('reports:create', v_context) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    INSERT INTO public.service_reports (order_line_id, order_service_item_id, reported_by, description, current_proof_urls, status)
    SELECT order_line_id, id, (select get_current_profile_id()), p_description, p_proof_urls, 'new' FROM public.order_service_items WHERE id = p_order_service_item_id RETURNING id, order_line_id INTO new_report_id, v_order_line_id;
    IF v_order_line_id IS NULL THEN RAISE EXCEPTION 'Invalid service item ID.'; END IF;
    PERFORM 1 FROM public.service_reports WHERE order_service_item_id = p_order_service_item_id AND status = 'new' AND id <> new_report_id;
    IF FOUND THEN DELETE FROM public.service_reports WHERE id = new_report_id; RAISE EXCEPTION 'This item already has an active report.'; END IF;
    RETURN new_report_id;
END;$function$
;

CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ 
  SELECT (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid; 
$function$
;

CREATE OR REPLACE FUNCTION public.finish_work_session_idem_v1(p_session_id uuid, p_outputs jsonb, p_activity_rows jsonb, p_overrun_reason text, p_idem_key text, p_overrun_type text, p_overrun_proof_urls text[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_session public.work_sessions%ROWTYPE;
    v_order_line_id UUID;
    v_order_id UUID;
    v_service_type TEXT;
    output_item JSONB;
    activity_item JSONB;
    v_delta NUMERIC;
    v_current_order_status TEXT;
    v_context jsonb;
    v_pilot_service_type TEXT; -- For pilot cycle logic
BEGIN
    -- Phần logic gốc từ schema - giữ nguyên
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Phiên làm việc không tồn tại.'; END IF;
    IF v_session.ended_at IS NOT NULL THEN RETURN; END IF;

    v_order_line_id := v_session.order_line_id;

    -- Lấy ngữ cảnh để kiểm tra quyền override
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    -- Lấy thông tin trạng thái và loại dịch vụ
    SELECT
        ol.id,
        o.id,
        (SELECT a.name FROM product_variant_attributes pva
         JOIN attributes a ON pva.attribute_id = a.id
         WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type,
        o.status
    INTO
        v_order_line_id,
        v_order_id,
        v_service_type,
        v_current_order_status
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_order_line_id;

    -- Lưu lại service_type cho pilot cycle logic
    v_pilot_service_type := v_service_type;

    -- So sánh với tên variant đã được chuẩn hóa
    IF v_current_order_status <> 'pending_completion' THEN
        IF v_service_type IN ('Service - Pilot', 'Pilot') THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    END IF;

    -- Xử lý outputs - giữ nguyên logic gốc để đảm bảo data được lưu
    IF p_outputs IS NOT NULL THEN
        FOR output_item IN SELECT * FROM jsonb_array_elements(p_outputs)
        LOOP
            -- Tính delta như logic gốc: current_value - start_value
            v_delta := (output_item->>'current_value')::numeric - (output_item->>'start_value')::numeric;

            -- Chỉ insert nếu delta khác 0
            IF v_delta <> 0 THEN
                INSERT INTO public.work_session_outputs (work_session_id, order_service_item_id, start_value, delta, start_proof_url, end_proof_url, params)
                VALUES (
                    p_session_id,
                    (output_item->>'item_id')::uuid,
                    (output_item->>'start_value')::numeric,
                    v_delta,
                    output_item->>'start_proof_url',
                    output_item->>'end_proof_url',
                    output_item->'params'
                );

                -- Update done_qty trong order_service_items như logic gốc
                UPDATE public.order_service_items
                SET done_qty = done_qty + v_delta
                WHERE id = (output_item->>'item_id')::uuid;
            END IF;
        END LOOP;
    END IF;

    IF p_activity_rows IS NOT NULL THEN
        FOR activity_item IN SELECT * FROM jsonb_array_elements(p_activity_rows)
        LOOP
            -- Logic gốc: activity cũng được insert vào work_session_outputs
            INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, delta, params)
            VALUES (p_session_id, (activity_item->>'item_id')::uuid, (activity_item->>'delta')::numeric, activity_item->'params');
        END LOOP;
    END IF;

    -- Kết thúc phiên - giữ nguyên logic
    UPDATE public.work_sessions
    SET
        ended_at = now(),
        overrun_reason = p_overrun_reason,
        overrun_type = p_overrun_type,
        overrun_proof_urls = p_overrun_proof_urls
    WHERE id = p_session_id;

    -- *** THÊM LOGIC PILOT CYCLE CHO FINISH SESSION ***
    IF v_pilot_service_type IN ('Service - Pilot', 'Pilot') AND
       v_current_order_status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN

        -- Bắt đầu nghỉ nếu không phải customer_playing
        UPDATE order_lines
        SET
            paused_at = CASE
                WHEN v_current_order_status = 'customer_playing' THEN paused_at  -- Khách chơi -> vẫn online
                ELSE now()                                             -- Thật sự nghỉ
            END
        WHERE id = v_order_line_id;

        -- Cập nhật pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);

        -- Kiểm tra điều kiện reset
        PERFORM public.check_and_reset_pilot_cycle(v_order_line_id);
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_boosting_filter_options()
 RETURNS TABLE(channels text[], service_types text[], package_types text[], statuses text[])
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  WITH base_data AS (
    SELECT DISTINCT
      ch.code as channel_code,
      pv.display_name as service_type,
      o.package_type,
      o.status
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE o.game_code = 'DIABLO_4'
      AND o.status <> 'draft'
  )
  SELECT
    ARRAY_AGG(DISTINCT bd.channel_code ORDER BY bd.channel_code) FILTER (WHERE bd.channel_code IS NOT NULL) as channels,
    ARRAY_AGG(DISTINCT bd.service_type ORDER BY bd.service_type) FILTER (WHERE bd.service_type IS NOT NULL) as service_types,
    ARRAY_AGG(DISTINCT bd.package_type ORDER BY bd.package_type) FILTER (WHERE bd.package_type IS NOT NULL) as package_types,
    ARRAY_AGG(DISTINCT bd.status ORDER BY bd.status) FILTER (WHERE bd.status IS NOT NULL) as statuses
  FROM base_data bd;
$function$
;

CREATE OR REPLACE FUNCTION public.get_boosting_order_detail_v1(p_line_id uuid)
 RETURNS json
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  SELECT json_build_object(
    'id', ol.id,
    'line_id', ol.id,
    'order_id', o.id,
    'created_at', o.created_at,
    'updated_at', o.updated_at,
    'status', o.status,
    'channel_code', ch.code,
    'customer_name', p.name,
    'deadline', ol.deadline_to,
    'btag', acc.btag,
    'login_id', acc.login_id,
    'login_pwd', acc.login_pwd,
    'service_type', pv.display_name,
    'package_type', o.package_type,
    'package_note', o.package_note,
    'action_proof_urls', ol.action_proof_urls,
    'machine_info', ol.machine_info,
    'paused_at', ol.paused_at,
    'pilot_warning_level', ol.pilot_warning_level,
    'pilot_is_blocked', ol.pilot_is_blocked,
    'pilot_cycle_start_at', ol.pilot_cycle_start_at,
    'pilot_online_hours', CASE
        WHEN ol.paused_at IS NOT NULL THEN
            EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
        ELSE
            EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
    END,
    'service_items', (
      SELECT json_agg(
        json_build_object(
          'id', si.id,
          'kind_code', k.code,
          'kind_name', k.name,
          'params', si.params,
          'plan_qty', si.plan_qty,
          'done_qty', si.done_qty,
          'active_report_id', (SELECT sr.id FROM service_reports sr WHERE sr.order_service_item_id = si.id AND sr.status = 'new' LIMIT 1)
        )
      )
      FROM public.order_service_items si
      JOIN public.attributes k ON si.service_kind_id = k.id
      WHERE si.order_line_id = ol.id
    ),
    'active_session', (
      SELECT json_build_object(
        'session_id', ws.id,
        'farmer_id', ws.farmer_id,
        'farmer_name', pr.display_name,
        'start_state', ws.start_state
      )
      FROM public.work_sessions ws
      JOIN public.profiles pr ON ws.farmer_id = pr.id
      WHERE ws.order_line_id = ol.id AND ws.ended_at IS NULL
      LIMIT 1
    )
  )
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  JOIN public.parties p ON o.party_id = p.id
  LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
  LEFT JOIN public.channels ch ON o.channel_id = ch.id
  LEFT JOIN public.customer_accounts acc ON ol.customer_account_id = acc.id
  WHERE ol.id = p_line_id;
$function$
;

CREATE OR REPLACE FUNCTION public.get_boosting_orders_v3(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0, p_channels text[] DEFAULT NULL::text[], p_statuses text[] DEFAULT NULL::text[], p_service_types text[] DEFAULT NULL::text[], p_package_types text[] DEFAULT NULL::text[], p_customer_name text DEFAULT NULL::text, p_assignee text DEFAULT NULL::text, p_delivery_status text DEFAULT NULL::text, p_review_status text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, order_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, status text, channel_code text, customer_name text, deadline timestamp with time zone, btag text, login_id text, login_pwd text, service_type text, package_type text, package_note text, assignees_text text, service_items jsonb, review_id uuid, machine_info text, paused_at timestamp with time zone, delivered_at timestamp with time zone, action_proof_urls text[], pilot_warning_level integer, pilot_is_blocked boolean, pilot_cycle_start_at timestamp with time zone, total_count bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  WITH active_farmers AS (
    SELECT
      ws.order_line_id,
      STRING_AGG(p.display_name, ', ') as farmer_names
    FROM public.work_sessions ws
    JOIN public.profiles p ON ws.farmer_id = p.id
    WHERE ws.ended_at IS NULL
    GROUP BY ws.order_line_id
  ),
  line_items AS (
    SELECT
      osi.order_line_id,
      jsonb_agg(
        jsonb_build_object(
          'id', osi.id,
          'kind_code', a_kind.code,
          'kind_name', a_kind.name,
          'params', osi.params,
          'plan_qty', osi.plan_qty,
          'done_qty', osi.done_qty,
          'active_report_id', (SELECT sr.id FROM service_reports sr WHERE sr.order_service_item_id = osi.id AND sr.status = 'new' LIMIT 1)
        ) ORDER BY a_kind.name
      ) AS items
    FROM public.order_service_items osi
    JOIN public.attributes a_kind ON osi.service_kind_id = a_kind.id
    GROUP BY osi.order_line_id
  ),
  base_query AS (
    SELECT
      ol.id,
      o.id as order_id,
      o.created_at,
      o.updated_at,
      o.status,
      ch.code as channel_code,
      p.name as customer_name,
      ol.deadline_to as deadline,
      ca.btag,
      ca.login_id,
      ca.login_pwd,
      pv.display_name as service_type,
      o.package_type,
      o.package_note,
      af.farmer_names as assignees_text,
      li.items as service_items,
      (SELECT r.id FROM public.order_reviews r WHERE r.order_line_id = ol.id LIMIT 1) as review_id,
      ol.machine_info,
      ol.paused_at,
      o.delivered_at,
      ol.action_proof_urls,
      -- Add pilot warning fields
      COALESCE(ol.pilot_warning_level, 0) as pilot_warning_level,
      COALESCE(ol.pilot_is_blocked, FALSE) as pilot_is_blocked,
      COALESCE(ol.pilot_cycle_start_at, o.created_at) as pilot_cycle_start_at,
      -- Add sorting columns for ORDER BY (using old rule with customer_playing before pending_completion)
      CASE o.status
        WHEN 'new' THEN 1
        WHEN 'in_progress' THEN 2
        WHEN 'pending_pilot' THEN 3
        WHEN 'paused_selfplay' THEN 4
        WHEN 'customer_playing' THEN 5
        WHEN 'pending_completion' THEN 6
        WHEN 'completed' THEN 7
        WHEN 'cancelled' THEN 8
        ELSE 99
      END as status_order
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    JOIN public.parties p ON o.party_id = p.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id
    LEFT JOIN line_items li ON ol.id = li.order_line_id
    LEFT JOIN active_farmers af ON ol.id = af.order_line_id
    WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
      -- Filter by channels
      AND (p_channels IS NULL OR ch.code = ANY(p_channels))
      -- Filter by statuses
      AND (p_statuses IS NULL OR o.status = ANY(p_statuses))
      -- Filter by service types (using display_name from product_variants)
      AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
      -- Filter by package types
      AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
      -- Filter by customer name (case-insensitive partial match)
      AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || p_customer_name || '%'))
      -- Filter by assignee (case-insensitive partial match)
      AND (p_assignee IS NULL OR LOWER(af.farmer_names) LIKE LOWER('%' || p_assignee || '%'))
  ),
  filtered_query AS (
    SELECT * FROM base_query
    -- Additional filtering for delivery status if specified
    WHERE
      CASE
        WHEN p_delivery_status = 'delivered' THEN delivered_at IS NOT NULL
        WHEN p_delivery_status = 'not_delivered' THEN delivered_at IS NULL
        ELSE TRUE
      END
      -- Additional filtering for review status if specified
      AND CASE
        WHEN p_review_status = 'reviewed' THEN review_id IS NOT NULL
        WHEN p_review_status = 'not_reviewed' THEN review_id IS NULL
        ELSE TRUE
      END
  ),
  counted_query AS (
    SELECT *, COUNT(*) OVER() as total_count FROM filtered_query
  )
  SELECT
    id,
    order_id,
    created_at,
    updated_at,
    status,
    channel_code,
    customer_name,
    deadline,
    btag,
    login_id,
    login_pwd,
    service_type,
    package_type,
    package_note,
    assignees_text,
    service_items,
    review_id,
    machine_info,
    paused_at,
    delivered_at,
    action_proof_urls,
    pilot_warning_level,
    pilot_is_blocked,
    pilot_cycle_start_at,
    total_count
  FROM counted_query
  ORDER BY
    -- Same sorting logic as before
    status_order,
    assignees_text ASC NULLS LAST,
    delivered_at ASC NULLS FIRST,
    review_id ASC NULLS FIRST,
    -- Add pilot cycle sorting (non-blocked first, lower warning first)
    pilot_is_blocked ASC NULLS LAST,
    pilot_warning_level ASC NULLS LAST,
    -- For completed orders, prioritize recently completed ones first
    CASE WHEN status = 'completed' THEN updated_at ELSE NULL END DESC NULLS LAST,
    deadline ASC NULLS LAST
  LIMIT p_limit OFFSET p_offset;
$function$
;

CREATE OR REPLACE FUNCTION public.get_current_profile_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  SELECT id
  FROM public.profiles
  WHERE auth_id = auth.uid();
$function$
;

CREATE OR REPLACE FUNCTION public.get_customers_by_channel_v1(p_channel_code text)
 RETURNS TABLE(name text)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  SELECT DISTINCT p.name
  FROM public.parties p
  JOIN public.orders o ON o.party_id = p.id
  JOIN public.channels c ON o.channel_id = c.id
  WHERE c.code = p_channel_code AND p.type = 'customer'
  ORDER BY p.name;
$function$
;

CREATE OR REPLACE FUNCTION public.get_last_item_proof_v1(p_item_ids uuid[])
 RETURNS TABLE(item_id uuid, last_start_proof_url text, last_end_proof_url text, last_end numeric, last_delta numeric, last_exp_percent numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  WITH ranked_outputs AS (
    SELECT 
      wso.order_service_item_id, 
      wso.start_proof_url, 
      wso.end_proof_url, 
      (wso.start_value + wso.delta) as end_value, 
      wso.delta, (wso.params->>'exp_percent')::numeric as exp_percent, 
      ROW_NUMBER() OVER (PARTITION BY wso.order_service_item_id ORDER BY ws.ended_at DESC, wso.id DESC) as rn 
    FROM public.work_session_outputs wso 
    LEFT JOIN public.work_sessions ws ON wso.work_session_id = ws.id 
    WHERE 
      wso.order_service_item_id = ANY(p_item_ids) 
      AND (wso.params->>'label') IS NULL
      AND wso.is_obsolete = FALSE
  )
  SELECT 
    ro.order_service_item_id, 
    ro.start_proof_url, 
    ro.end_proof_url, 
    ro.end_value, 
    ro.delta, 
    ro.exp_percent 
  FROM ranked_outputs ro 
  WHERE ro.rn = 1;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_assignments()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  SELECT jsonb_agg(
    jsonb_build_object(
      'role', r.code, 'permissions', p.codes,
      'game_code', game_attr.code, 'game_name', game_attr.name, -- THÊM game_name
      'business_area_code', area_attr.code, 'business_area_name', area_attr.name -- THÊM business_area_name VÀ ĐỔI TÊN business_area
    )
  )
  FROM public.user_role_assignments ura
  JOIN public.roles r ON ura.role_id = r.id
  LEFT JOIN (SELECT rp.role_id, jsonb_agg(p.code) as codes FROM public.role_permissions rp JOIN public.permissions p ON rp.permission_id = p.id GROUP BY rp.role_id) p ON ura.role_id = p.role_id
  LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
  LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
  WHERE ura.user_id = (select auth.uid());
$function$
;

CREATE OR REPLACE FUNCTION public.get_reviews_for_order_line_v1(p_line_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  -- Kiểm tra quyền hạn trước khi trả về dữ liệu
  SELECT CASE
    WHEN has_permission('orders:view_reviews') THEN (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', r.id,
          'rating', r.rating,
          'comment', r.comment,
          'proof_urls', r.proof_urls,
          'created_at', r.created_at,
          'reviewer_name', p.display_name
        ) ORDER BY r.created_at DESC
      )
      FROM public.order_reviews r
      JOIN public.profiles p ON r.created_by = p.id
      WHERE r.order_line_id = p_line_id
    )
    ELSE
      '[]'::jsonb -- Trả về mảng rỗng nếu không có quyền
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_service_reports_v1(p_status text DEFAULT 'new'::text)
 RETURNS TABLE(report_id uuid, reported_at timestamp with time zone, report_status text, report_description text, report_proof_urls text[], reporter_name text, order_line_id uuid, customer_name text, channel_code text, service_type text, deadline timestamp with time zone, package_note text, btag text, login_id text, login_pwd text, reported_item jsonb)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT sr.id, sr.created_at, sr.status, sr.description, sr.current_proof_urls, reporter.display_name, ol.id, p.name, ch.code, (SELECT a.name FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1), ol.deadline_to, o.package_note, ca.btag, ca.login_id, ca.login_pwd, jsonb_build_object('id', osi.id, 'kind_code', a.code, 'params', osi.params, 'plan_qty', osi.plan_qty, 'done_qty', osi.done_qty)
  FROM public.service_reports sr JOIN public.profiles reporter ON sr.reported_by = reporter.id JOIN public.order_lines ol ON sr.order_line_id = ol.id JOIN public.orders o ON ol.order_id = o.id JOIN public.parties p ON o.party_id = p.id LEFT JOIN public.channels ch ON o.channel_id = ch.id LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id JOIN public.order_service_items osi ON sr.order_service_item_id = osi.id JOIN public.attributes a ON osi.service_kind_id = a.id
  WHERE has_permission('reports:view') AND sr.status = p_status ORDER BY sr.created_at ASC;
$function$
;

CREATE OR REPLACE FUNCTION public.get_session_history_v2(p_line_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT CASE
    WHEN has_permission('orders:view_all') THEN (
      SELECT jsonb_agg(
        jsonb_build_object(
          'session_id', ws.id,
          'started_at', ws.started_at,
          'ended_at', ws.ended_at,
          'farmer_name', p.display_name,
          
          -- <<< LOGIC CẢNH BÁO ĐÃ ĐƯỢC SỬA LẠI HOÀN CHỈNH >>>
          'has_zero_progress_item', (
            EXISTS (
              SELECT 1
              FROM public.work_session_outputs wso
              JOIN public.order_service_items osi ON wso.order_service_item_id = osi.id
              JOIN public.attributes a ON osi.service_kind_id = a.id
              WHERE wso.work_session_id = ws.id
                AND a.code <> 'MYTHIC' -- Bỏ qua kind Mythic
                AND (
                  -- Trường hợp 1: Các kind khác leveling có delta = 0
                  (a.code <> 'LEVELING' AND wso.delta = 0)
                  OR
                  -- Trường hợp 2: Kind Leveling có delta = 0 VÀ %EXP không đổi
                  (
                    a.code = 'LEVELING' AND wso.delta = 0 AND
                    COALESCE((wso.params->>'exp_percent')::numeric, -1) = 
                    COALESCE(
                        (
                          SELECT (elem->>'start_exp')::numeric
                          FROM jsonb_array_elements(ws.start_state) AS elem
                          WHERE elem->>'item_id' = wso.order_service_item_id::text
                          LIMIT 1
                        ), 
                        -1
                    )
                  )
                )
            )
          ),
          
          'outputs', (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', osi.id,
                'kind_code', a.code,
                'params', osi.params,
                'plan_qty', osi.plan_qty,
                'done_qty', osi.done_qty,
                'session_start_value', wso.start_value,
                'session_end_value', wso.start_value + wso.delta,
                'session_delta', wso.delta,
                'start_proof_url', wso.start_proof_url,
                'end_proof_url', wso.end_proof_url,
                'is_activity', (wso.params->>'label' IS NOT NULL),
                'activity_label', wso.params->>'label'
              )
            )
            FROM public.work_session_outputs wso
            JOIN public.order_service_items osi ON wso.order_service_item_id = osi.id
            JOIN public.attributes a ON osi.service_kind_id = a.id
            WHERE wso.work_session_id = ws.id
          )
        ) ORDER BY ws.started_at DESC
      )
      FROM public.work_sessions ws
      JOIN public.profiles p ON ws.farmer_id = p.id
      WHERE ws.order_line_id = p_line_id AND ws.ended_at IS NOT NULL
    )
    ELSE
      '[]'::jsonb
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_auth_context_v1()
 RETURNS json
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT json_build_object(
    'roles', (
      SELECT json_agg(
        json_build_object(
          'role_code', r.code,
          'role_name', r.name,
          'game_code', g.code,
          'game_name', g.name,
          'business_area_code', ba.code,
          'business_area_name', ba.name
        )
      )
      FROM public.user_role_assignments ura
      JOIN public.roles r ON ura.role_id = r.id
      LEFT JOIN public.attributes g ON ura.game_attribute_id = g.id AND g.type = 'GAME'
      LEFT JOIN public.attributes ba ON ura.business_area_attribute_id = ba.id AND ba.type = 'BUSINESS_AREA'
      -- <<< SỬA LỖI Ở ĐÂY >>>
      WHERE ura.user_id = public.get_current_profile_id()
    ),
    'permissions', (
      SELECT json_agg(
        json_build_object(
          'permission_code', p.code,
          'game_code', g.code,
          'business_area_code', ba.code
        )
      )
      FROM public.user_role_assignments ura
      JOIN public.roles r ON ura.role_id = r.id
      JOIN public.role_permissions rp ON r.id = rp.role_id
      JOIN public.permissions p ON rp.permission_id = p.id
      LEFT JOIN public.attributes g ON ura.game_attribute_id = g.id AND g.type = 'GAME'
      LEFT JOIN public.attributes ba ON ura.business_area_attribute_id = ba.id AND ba.type = 'BUSINESS_AREA'
      -- <<< SỬA LỖI Ở ĐÂY >>>
      WHERE ura.user_id = public.get_current_profile_id()
    )
  );
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user_with_trial_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  trial_role_id uuid;
  user_display_name text;
  new_profile_id uuid;
BEGIN
  -- 1. Chuẩn bị display_name
  user_display_name := COALESCE(
    NEW.raw_user_meta_data ->> 'display_name',
    SPLIT_PART(NEW.email, '@', 1)
  );

  -- 2. TẠO DÒNG MỚI TRONG PROFILES VỚI CẤU TRÚC MỚI
  --    - profiles.id sẽ được tự động tạo bởi `default gen_random_uuid()`
  --    - profiles.auth_id sẽ là ID từ auth.users (NEW.id)
  INSERT INTO public.profiles (auth_id, display_name)
  VALUES (NEW.id, user_display_name)
  RETURNING id INTO new_profile_id; -- Lấy id của profile vừa tạo

  -- 3. Lấy ID của vai trò 'trial'
  SELECT id INTO trial_role_id FROM public.roles WHERE code = 'trial';

  -- 4. Gán vai trò 'trial' nếu tìm thấy, sử dụng profile_id mới
  IF trial_role_id IS NOT NULL THEN
    INSERT INTO public.user_role_assignments (user_id, role_id)
    VALUES (new_profile_id, trial_role_id);
  ELSE
    RAISE WARNING 'Role with code ''trial'' not found. Skipping role assignment for user %', NEW.id;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_orders_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.has_permission(p_permission_code text, p_context jsonb DEFAULT '{}'::jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    -- SỬA LỖI: Lấy profile_id của người dùng đang đăng nhập thay vì auth.uid()
    v_profile_id uuid := public.get_current_profile_id();
    v_context_game_code text := p_context->>'game_code';
    v_context_business_area text := p_context->>'business_area_code';
BEGIN
    -- Nếu không tìm thấy profile cho người dùng, họ không có quyền gì cả
    IF v_profile_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Thực hiện kiểm tra quyền bằng cách so sánh với profile_id
    RETURN EXISTS (
        SELECT 1
        FROM public.user_role_assignments ura
        JOIN public.role_permissions rp ON ura.role_id = rp.role_id
        JOIN public.permissions p ON rp.permission_id = p.id
        LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
        LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
        -- SỬA LỖI: Điều kiện WHERE bây giờ so sánh đúng profile_id
        WHERE ura.user_id = v_profile_id AND p.code = p_permission_code
          AND (ura.game_attribute_id IS NULL OR game_attr.code = v_context_game_code)
          AND (ura.business_area_attribute_id IS NULL OR area_attr.code = v_context_business_area)
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.mark_order_as_delivered_v1(p_order_id uuid, p_is_delivered boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy ngữ cảnh của đơn hàng đang được cập nhật
  SELECT 
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_context
  FROM public.orders o
  WHERE o.id = p_order_id;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật trạng thái (logic cũ giữ nguyên)
  UPDATE public.orders
  SET delivered_at = CASE 
                      WHEN p_is_delivered THEN NOW() 
                      ELSE NULL 
                    END
  WHERE id = p_order_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.resolve_service_report_v1(p_report_id uuid, p_resolver_notes text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    IF NOT has_permission('reports:resolve') THEN RAISE EXCEPTION 'Authorization failed.'; END IF;
    UPDATE public.service_reports SET status = 'resolved', resolved_at = now(), resolved_by = (select auth.uid()), resolver_notes = p_resolver_notes WHERE id = p_report_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.start_work_session_v1(p_order_line_id uuid, p_start_state jsonb, p_initial_note text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_order_id UUID;
    v_current_status TEXT;
    v_paused_at TIMESTAMPTZ;
    v_paused_duration INTERVAL;
    new_session_id UUID;
    v_context jsonb;
    v_order_created_at TIMESTAMPTZ;
    v_service_type TEXT;
BEGIN
    -- Lấy ngữ cảnh và các thông tin cần thiết
    SELECT o.id, o.status, ol.paused_at, o.created_at,
           (SELECT a.name FROM product_variant_attributes pva JOIN attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type,
           jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_order_id, v_current_status, v_paused_at, v_order_created_at, v_service_type, v_context
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE ol.id = p_order_line_id;

    IF v_order_id IS NULL THEN RAISE EXCEPTION 'Order line not found'; END IF;

    -- <<< THÊM CÁC KIỂM TRA MỚI Ở ĐÂY >>>
    -- 1. Kiểm tra xem có phiên làm việc khác đang chạy không
    PERFORM 1 FROM public.work_sessions WHERE order_line_id = p_order_line_id AND ended_at IS NULL;
    IF FOUND THEN
        RAISE EXCEPTION 'Đơn hàng này đã có một phiên làm việc đang hoạt động.';
    END IF;
    
    -- 2. Kiểm tra xem khách hàng có đang chơi không
    IF v_current_status = 'customer_playing' THEN
        RAISE EXCEPTION 'Không thể bắt đầu phiên làm việc khi khách đang chơi.';
    END IF;

    -- Các logic còn lại của hàm
    IF NOT has_permission('work_session:start', v_context) THEN
        RAISE EXCEPTION 'Bạn không có quyền bắt đầu phiên làm việc cho dịch vụ này.';
    END IF;

    IF v_current_status IN ('completed', 'cancelled') THEN
        RAISE EXCEPTION 'Không thể bắt đầu phiên làm việc cho đơn hàng đã hoàn thành hoặc hủy.';
    END IF;

    IF v_current_status IN ('new', 'pending_pilot', 'paused_selfplay') THEN
        UPDATE public.orders SET status = 'in_progress' WHERE id = v_order_id;
    END IF;

    INSERT INTO public.work_sessions (order_line_id, farmer_id, notes, start_state, unpaused_duration)
    VALUES (p_order_line_id, public.get_current_profile_id(), p_initial_note, p_start_state, v_paused_duration)
    RETURNING id INTO new_session_id;

    IF v_service_type IN ('Service - Pilot', 'Pilot') AND
       v_current_status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        UPDATE order_lines SET paused_at = NULL WHERE id = p_order_line_id;
        PERFORM public.update_pilot_cycle_warning(p_order_line_id);
    END IF;

    RETURN new_session_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.submit_order_review_v1(p_line_id uuid, p_rating numeric, p_comment text, p_proof_urls text[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$BEGIN
  -- SỬA LẠI: Kiểm tra quyền 'orders:add_review'
  IF NOT has_permission('orders:add_review') THEN
    RAISE EXCEPTION 'User does not have permission to submit a review';
  END IF;

  INSERT INTO public.order_reviews (order_line_id, rating, comment, proof_urls, created_by)
  VALUES (p_line_id, p_rating, p_comment, p_proof_urls, get_current_profile_id());
END;$function$
;

CREATE OR REPLACE FUNCTION public.toggle_customer_playing(p_order_id uuid, p_enable_customer_playing boolean, p_current_user_id uuid)
 RETURNS TABLE(success boolean, message text, new_status text, new_deadline timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    -- <<< SỬA LỖI 1: Loại bỏ v_order_record, thay bằng các biến đơn giản >>>
    v_paused_at timestamptz;
    v_order_line_id uuid;
    v_current_status text;
    v_current_deadline timestamptz;
    v_new_deadline timestamptz;
    v_now timestamptz := now();
    v_service_type text;
BEGIN
    -- <<< SỬA LỖI 2: Cập nhật lại câu lệnh SELECT ... INTO ... >>>
    SELECT
        o.status,
        ol.deadline_to,
        COALESCE(
            (SELECT a.name FROM product_variant_attributes pva JOIN attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1),
            'Unknown'
        ),
        ol.paused_at,
        ol.id
    INTO 
        v_current_status, 
        v_current_deadline, 
        v_service_type, 
        v_paused_at, 
        v_order_line_id
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE o.id = p_order_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Đơn hàng không tồn tại'::text, NULL::text, NULL::timestamp with time zone;
        RETURN;
    END IF;

    -- Sử dụng v_order_line_id đã lấy được để kiểm tra phiên làm việc
    IF p_enable_customer_playing THEN
        PERFORM 1 FROM public.work_sessions 
        WHERE order_line_id = v_order_line_id AND ended_at IS NULL;
        IF FOUND THEN
            RETURN QUERY SELECT false, 'Không thể bật chế độ khách chơi khi đang có phiên làm việc hoạt động.'::text, NULL::text, NULL::timestamptz;
            RETURN;
        END IF;
    END IF;

    -- Logic còn lại giữ nguyên
    IF v_service_type = 'Selfplay' THEN
        RETURN QUERY SELECT false, 'Chỉ áp dụng cho đơn hàng pilot'::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_current_status NOT IN ('in_progress', 'pending_pilot', 'customer_playing') THEN
        RETURN QUERY SELECT false, 'Chỉ áp dụng cho đơn hàng đang thực hiện'::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF p_enable_customer_playing THEN
        UPDATE order_lines SET paused_at = v_now WHERE id = v_order_line_id;
        UPDATE orders SET status = 'customer_playing', updated_at = v_now WHERE id = p_order_id;
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);
        RETURN QUERY SELECT true, 'Đã chuyển sang trạng thái Khách chơi'::text, 'customer_playing'::text, v_current_deadline;
        RETURN;
    ELSE
        -- <<< SỬA LỖI 3: Thay thế v_order_record.paused_at bằng v_paused_at >>>
        IF v_paused_at IS NOT NULL AND v_current_deadline IS NOT NULL THEN
            v_new_deadline := v_current_deadline + (v_now - v_paused_at);
        ELSE
            v_new_deadline := v_current_deadline;
        END IF;
        
        UPDATE order_lines SET paused_at = CASE WHEN EXISTS (SELECT 1 FROM work_sessions WHERE order_line_id = v_order_line_id AND ended_at IS NULL) THEN NULL ELSE v_now END WHERE id = v_order_line_id;
        UPDATE orders SET status = 'pending_pilot', updated_at = v_now WHERE id = p_order_id;
        UPDATE order_lines SET deadline_to = v_new_deadline WHERE id = v_order_line_id;
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);
        PERFORM public.check_and_reset_pilot_cycle(v_order_line_id);
        RETURN QUERY SELECT true, 'Đã tiếp tục thực hiện đơn hàng'::text, 'pending_pilot'::text, v_new_deadline;
        RETURN;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_audit_row_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE v_actor_id uuid; v_old_row_json jsonb; v_new_row_json jsonb; v_diff jsonb; v_entity_id uuid;
BEGIN
    BEGIN v_actor_id := (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')::uuid; EXCEPTION WHEN OTHERS THEN v_actor_id := NULL; END;
    IF (TG_OP = 'UPDATE') THEN v_old_row_json := to_jsonb(OLD); v_new_row_json := to_jsonb(NEW);
    ELSIF (TG_OP = 'DELETE') THEN v_old_row_json := to_jsonb(OLD); v_new_row_json := NULL;
    ELSIF (TG_OP = 'INSERT') THEN v_old_row_json := NULL; v_new_row_json := to_jsonb(NEW);
    END IF;
    v_diff := audit_diff_v1(v_old_row_json, v_new_row_json);
    BEGIN
        IF v_new_row_json ? 'id' THEN v_entity_id := (v_new_row_json ->> 'id')::uuid;
        ELSIF v_old_row_json ? 'id' THEN v_entity_id := (v_old_row_json ->> 'id')::uuid;
        ELSE v_entity_id := NULL;
        END IF;
    EXCEPTION WHEN OTHERS THEN v_entity_id := NULL;
    END;
    INSERT INTO public.audit_logs (actor, entity, entity_id, action, op, diff, row_old, row_new)
    VALUES (v_actor_id, TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME, v_entity_id, LOWER(TG_OP), TG_OP, v_diff, v_old_row_json, v_new_row_json);
    RETURN COALESCE(NEW, OLD);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Only update for pilot orders when pilot_cycle_start_at is NULL
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.order_lines ol ON o.id = ol.order_id
        JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND ol.pilot_cycle_start_at IS NULL
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Initialize pilot cycle start time
        UPDATE public.order_lines
        SET pilot_cycle_start_at = NEW.started_at
        WHERE id = NEW.order_line_id;

        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Only initialize for new pilot orders
    IF EXISTS (
        SELECT 1 FROM public.product_variants pv
        WHERE pv.id = NEW.variant_id
        AND pv.display_name = 'Service - Pilot'
    ) THEN
        -- Initialize pilot cycle start time to current time
        NEW.pilot_cycle_start_at := NOW();
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.product_variants pv ON o.id = NEW.order_id
        WHERE pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.id);

        -- Check and reset if conditions met
        PERFORM public.check_and_reset_pilot_cycle(NEW.id);
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.order_lines ol ON o.id = ol.order_id
        JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);

        -- Check and reset if conditions met
        PERFORM public.check_and_reset_pilot_cycle(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tr_check_all_items_completed_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
DECLARE v_order_line_id UUID; v_order_id UUID; v_current_order_status TEXT; v_service_type TEXT; total_items INT; completed_items INT;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.done_qty <> OLD.done_qty THEN
        v_order_line_id := NEW.order_line_id;
        SELECT ol.order_id, o.status,
               (SELECT a.name FROM product_variant_attributes pva
                JOIN attributes a ON pva.attribute_id = a.id
                WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type
        INTO v_order_id, v_current_order_status, v_service_type
        FROM public.order_lines ol
        JOIN public.orders o ON ol.order_id = o.id
        WHERE ol.id = v_order_line_id;

        IF v_current_order_status IN ('completed', 'cancelled', 'pending_completion') THEN RETURN NEW; END IF;
        SELECT count(*) INTO total_items FROM public.order_service_items WHERE order_line_id = v_order_line_id;
        SELECT count(*) INTO completed_items FROM public.order_service_items WHERE order_line_id = v_order_line_id AND done_qty >= COALESCE(plan_qty, 0);
        IF total_items > 0 AND total_items = completed_items THEN
            -- Chỉ dừng deadline cho Selfplay khi pending_completion
            IF v_current_order_status = 'in_progress' AND v_service_type = 'Service - Selfplay' THEN
                UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id;
            END IF;
            UPDATE public.orders SET status = 'pending_completion' WHERE id = v_order_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.try_uuid(p text)
 RETURNS uuid
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public'
AS $function$
begin
  return p::uuid;
exception when others then
  return null;
end $function$
;

CREATE OR REPLACE FUNCTION public.update_action_proofs_v1(p_line_id uuid, p_new_urls text[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy ngữ cảnh từ đơn hàng để kiểm tra quyền
  SELECT 
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật bảng (logic cũ giữ nguyên)
  UPDATE public.order_lines
  SET action_proof_urls = p_new_urls
  WHERE id = p_line_id;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_order_details_v1(p_line_id uuid, p_service_type text, p_deadline timestamp with time zone, p_package_note text, p_btag text, p_login_id text, p_login_pwd text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_order_id uuid;
  v_customer_account_id uuid;
  v_product_id uuid;
  v_variant_id uuid;
  v_variant_name text;
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy các ID liên quan và ngữ cảnh từ order_line
  SELECT 
    ol.order_id, 
    ol.customer_account_id,
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_order_id, 
    v_customer_account_id,
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  IF v_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật các bảng liên quan (logic còn lại giữ nguyên)
  -- 3.1 Cập nhật deadline trên order_lines
  UPDATE public.order_lines
  SET deadline_to = p_deadline
  WHERE id = p_line_id;

  -- 3.2 Cập nhật package_note trên orders
  UPDATE public.orders
  SET package_note = p_package_note
  WHERE id = v_order_id;

  -- 3.3 Cập nhật thông tin tài khoản khách hàng (nếu có)
  IF v_customer_account_id IS NOT NULL THEN
    UPDATE public.customer_accounts
    SET 
      btag = p_btag,
      login_id = p_login_id,
      login_pwd = p_login_pwd
    WHERE id = v_customer_account_id;
  END IF;

  -- 3.4 Cập nhật Service Type (thông qua product_variant)
  IF p_service_type IS NOT NULL THEN
    SELECT prod.id INTO v_product_id FROM public.products prod WHERE prod.name = 'Boosting Service' LIMIT 1;
    
    IF v_product_id IS NOT NULL THEN
      v_variant_name := 'Service-' || lower(p_service_type);

      WITH new_variant AS (
        INSERT INTO public.product_variants (product_id, display_name)
        VALUES (v_product_id, v_variant_name)
        ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
        RETURNING id
      )
      SELECT id INTO v_variant_id FROM new_variant;

      UPDATE public.order_lines
      SET variant_id = v_variant_id
      WHERE id = p_line_id;
    END IF;
  END IF;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_order_line_machine_info_v1(p_line_id uuid, p_machine_info text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;
    UPDATE public.order_lines
    SET machine_info = p_machine_info
    WHERE id = p_line_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_pilot_cycle_warning(p_order_line_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_pilot_is_blocked BOOLEAN;
    v_pilot_warning_level INTEGER;
    v_hours_online NUMERIC;
    v_current_paused_at TIMESTAMP WITH TIME ZONE;
    v_cycle_start_at TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get order information
    SELECT pv.display_name, o.status, ol.pilot_is_blocked, ol.pilot_warning_level, ol.paused_at,
           COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
    INTO v_service_type, v_order_status, v_pilot_is_blocked, v_pilot_warning_level, v_current_paused_at, v_cycle_start_at
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
    JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Calculate online hours from current cycle start time
    IF v_current_paused_at IS NOT NULL THEN
        -- Currently resting
        v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    ELSE
        -- Currently online
        v_hours_online := EXTRACT(EPOCH FROM (NOW() - v_cycle_start_at)) / 3600;
    END IF;

    -- Update warning level
    UPDATE public.order_lines
    SET
        pilot_warning_level = CASE
            WHEN v_hours_online >= 6 * 24 THEN 2  -- >= 6 days
            WHEN v_hours_online >= 5 * 24 THEN 1  -- >= 5 days
            ELSE 0
        END,
        pilot_is_blocked = (v_hours_online >= 6 * 24)
    WHERE id = p_order_line_id;
END;
$function$
;

create policy "Allow privileged users to read audit logs"
on "public"."audit_logs"
as permissive
for select
to authenticated
using (public.has_permission('system:view_audit_logs'::text));


create policy "Allow admin to manage debug logs"
on "public"."debug_log"
as permissive
for all
to authenticated
using (public.has_permission('admin:manage_roles'::text))
with check (public.has_permission('admin:manage_roles'::text));


create policy "Allow users with permission to add reviews"
on "public"."order_reviews"
as permissive
for insert
to public
with check (((created_by = auth.uid()) AND public.has_permission('orders:add_review'::text)));


create policy "Allow users with permission to view reviews"
on "public"."order_reviews"
as permissive
for select
to public
using (public.has_permission('orders:view_reviews'::text));


create policy "Allow admin to manage permissions"
on "public"."permissions"
as permissive
for all
to authenticated
using (public.has_permission('admin:manage_roles'::text))
with check (public.has_permission('admin:manage_roles'::text));


create policy "Allow admin to delete"
on "public"."role_permissions"
as permissive
for delete
to authenticated
using (public.has_permission('admin:manage_roles'::text));


create policy "Allow admin to insert"
on "public"."role_permissions"
as permissive
for insert
to authenticated
with check (public.has_permission('admin:manage_roles'::text));


create policy "Allow admin to update"
on "public"."role_permissions"
as permissive
for update
to authenticated
using (public.has_permission('admin:manage_roles'::text));


create policy "Allow managers to resolve reports"
on "public"."service_reports"
as permissive
for update
to authenticated
using (public.has_permission('reports:resolve'::text))
with check (public.has_permission('reports:resolve'::text));


create policy "Allow users to read relevant reports"
on "public"."service_reports"
as permissive
for select
to authenticated
using (((reported_by = ( SELECT auth.uid() AS uid)) OR public.has_permission('reports:view'::text)));


create policy "Allow admins to delete assignments"
on "public"."user_role_assignments"
as permissive
for delete
to authenticated
using (public.has_permission('admin:manage_roles'::text));


create policy "Allow admins to insert assignments"
on "public"."user_role_assignments"
as permissive
for insert
to authenticated
with check (public.has_permission('admin:manage_roles'::text));


create policy "Allow admins to update assignments"
on "public"."user_role_assignments"
as permissive
for update
to authenticated
using (public.has_permission('admin:manage_roles'::text));


create policy "Allow users to read their own, and admins all"
on "public"."user_role_assignments"
as permissive
for select
to authenticated
using (((user_id = auth.uid()) OR public.has_permission('admin:manage_roles'::text)));


CREATE TRIGGER tr_pilot_cycle_pause_change AFTER UPDATE ON public.order_lines FOR EACH ROW WHEN ((old.paused_at IS DISTINCT FROM new.paused_at)) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change();

CREATE TRIGGER tr_pilot_cycle_order_status_change AFTER UPDATE ON public.orders FOR EACH ROW WHEN ((old.status IS DISTINCT FROM new.status)) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_status_change();

CREATE TRIGGER tr_pilot_cycle_first_session AFTER INSERT ON public.work_sessions FOR EACH ROW WHEN ((new.ended_at IS NULL)) EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session();

CREATE TRIGGER tr_pilot_cycle_work_session_end AFTER UPDATE ON public.work_sessions FOR EACH ROW WHEN (((old.ended_at IS NULL) AND (new.ended_at IS NOT NULL))) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end();

CREATE TRIGGER tr_auto_initialize_pilot_cycle_on_order_create AFTER INSERT ON public.order_lines FOR EACH ROW EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create();

CREATE TRIGGER tr_auto_update_pilot_cycle_on_pause_change AFTER UPDATE OF paused_at ON public.order_lines FOR EACH ROW WHEN ((old.paused_at IS DISTINCT FROM new.paused_at)) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change();

CREATE TRIGGER tr_pilot_cycle_order_create BEFORE INSERT ON public.order_lines FOR EACH ROW EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create();

CREATE TRIGGER tr_after_update_order_service_items AFTER UPDATE ON public.order_service_items FOR EACH ROW EXECUTE FUNCTION public.tr_check_all_items_completed_v1();

CREATE TRIGGER on_orders_update BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.handle_orders_updated_at();

CREATE TRIGGER tr_auto_initialize_pilot_cycle_on_first_session AFTER INSERT ON public.work_sessions FOR EACH ROW EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session();

CREATE TRIGGER tr_auto_update_pilot_cycle_on_session_end AFTER UPDATE OF ended_at ON public.work_sessions FOR EACH ROW WHEN (((old.ended_at IS NULL) AND (new.ended_at IS NOT NULL))) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end();


drop trigger if exists "on_auth_user_created" on "auth"."users";

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_with_trial_role();

drop policy "Allow admins to delete proofs 1a09c6j_0" on "storage"."objects";


  create policy "Allow admins to delete proofs 1a09c6j_0"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'work-proofs'::text) AND public.has_permission('admin:manage_roles'::text)));



