-- Auto-update exchange rates every hour using pg_cron + pg_net
-- Uses async mode to avoid timeout - triggers Edge Function in background

-- Unschedule old job if exists
SELECT cron.unschedule('update-exchange-rates-hourly');

-- Create function to trigger Edge Function asynchronously
CREATE OR REPLACE FUNCTION update_exchange_rates_direct()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_request_id BIGINT;
    v_api_url TEXT := 'https://nxlrnwijsxqalcxyavkj.supabase.co/functions/v1/fetch-exchange-rates';
    v_anon_key TEXT := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzM3NzIsImV4cCI6MjA3NTg0OTc3Mn0.HHMZHjT3OHHfcqeAbagirwYFPlmRNjScDFMY7mpdPRw';
BEGIN
    -- Trigger Edge Function asynchronously (don't wait for response)
    -- The Edge Function will handle fetching from API and updating database
    v_request_id := net.http_post(
        url := v_api_url,
        headers := jsonb_build_object(
            'Authorization', 'Bearer ' || v_anon_key,
            'Content-Type', 'application/json'
        ),
        body := '{}'::jsonb,
        timeout_milliseconds := 30000
    );

    -- Return immediately - the Edge Function handles the update in background
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Exchange rates update triggered',
        'request_id', v_request_id,
        'timestamp', NOW()
    );
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION update_exchange_rates_direct() TO authenticated;

-- Schedule the cron job to run every hour at minute 0
SELECT cron.schedule(
    'update-exchange-rates-hourly',
    '0 * * * *',
    'SELECT update_exchange_rates_direct();'
);

-- Verify the cron job was created
SELECT
    jobid,
    jobname,
    schedule,
    command,
    active
FROM cron.job
WHERE jobname = 'update-exchange-rates-hourly';
