CREATE VIEW public.shipping_datamart AS (
  WITH i AS (
    SELECT 
      shipping_id, 
      (
        shipping_end_fact_datetime - shipping_start_fact_datetime
      ) AS full_day_at_shipping 
    FROM 
      public.shipping_status ss
  ), 
  a AS (
    SELECT 
      b.shipping_id, 
      (
        CASE WHEN b.shipping_end_fact_datetime > b.shipping_plan_datetime THEN '1' ELSE '0' END
      ) AS is_delay, 
      (
        CASE WHEN b.status = 'finished' THEN '1' ELSE '0' END
      ) AS is_shipping_finish, 
      (
        CASE WHEN b.shipping_end_fact_datetime > b.shipping_plan_datetime THEN (
          b.shipping_end_fact_datetime - b.shipping_plan_datetime
        ) ELSE '0' END
      ) AS delay_day_at_shipping 
    FROM 
      (
        SELECT 
          ss.shipping_id, 
          ss.shipping_end_fact_datetime, 
          s.shipping_plan_datetime, 
          ss.status 
        FROM 
          public.shipping_status ss 
          LEFT JOIN public.shipping s ON ss.shipping_id = s.shippingid
      ) AS b
  ), 
  c AS (
    SELECT 
      d.shipping_id, 
      (
        d.payment_amount *(
          d.shipping_country_base_rate + d.agreement_rate + d.shipping_transfer_rate
        )
      ) AS vat, 
      (
        d.payment_amount * d.agreement_commission
      ) AS profit 
    FROM 
      (
        SELECT 
          si.shipping_id, 
          si.payment_amount, 
          scr.shipping_country_base_rate, 
          sa.agreement_rate, 
          st.shipping_transfer_rate, 
          sa.agreement_commission 
        FROM 
          public.shipping_info si 
          LEFT JOIN public.shipping_country_rates scr ON si.shipping_id = scr.id 
          LEFT JOIN public.shipping_agreement sa ON si.shipping_id = sa.agreement_id 
          LEFT JOIN public.shipping_transfer st ON si.shipping_id = st.id
      ) AS d
  ) 
  SELECT 
    DISTINCT si.shipping_id, 
    si.vendor_id, 
    st.transfer_type, 
    i.full_day_at_shipping, 
    a.is_delay, 
    a.is_shipping_finish, 
    a.delay_day_at_shipping, 
    si.payment_amount, 
    c.vat, 
    c.profit 
  FROM 
    shipping_info si 
    LEFT JOIN shipping_transfer st ON si.shipping_transfer_id = st.id 
    LEFT JOIN shipping_status ss ON si.shipping_transfer_id = ss.shipping_id 
    LEFT JOIN a ON si.shipping_transfer_id = a.shipping_id 
    LEFT JOIN i ON si.shipping_transfer_id = i.shipping_id 
    LEFT JOIN c ON si.shipping_transfer_id = c.shipping_id
);

