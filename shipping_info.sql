DROP TABLE IF EXISTS public.shipping_info;

CREATE TABLE public.shipping_info(
  shipping_id int8 NOT NULL PRIMARY KEY,
  vendor_id int8 NULL,
  payment_amount numeric(14, 2) NULL,
  shipping_plan_datetime timestamp NULL,
  shipping_transfer_id int8 NOT NULL,
  shipping_agreement_id int8 NULL,
  shipping_country_rate_id int8 NOT NULL,
  FOREIGN KEY(shipping_transfer_id) REFERENCES public.shipping_transfer(id) ON UPDATE cascade,
  FOREIGN KEY(shipping_agreement_id) REFERENCES public.shipping_agreement(agreement_id) ON UPDATE cascade,
  FOREIGN KEY(shipping_country_rate_id) REFERENCES public.shipping_country_rates(id) ON UPDATE cascade
);

INSERT INTO public.shipping_info (shipping_id, vendor_id, payment_amount, shipping_plan_datetime, shipping_transfer_id, shipping_agreement_id, shipping_country_rate_id)

SELECT DISTINCT
  s.shippingid::int8 AS shipping_id,
  s.vendorid::int8 AS vendor_id,
  s.payment_amount::numeric(14, 2) AS payment_amount,
  s.shipping_plan_datetime::timestamp AS shipping_plan_datetime,
  st.shipping_transfer_id::int8,
  sa.shipping_agreement_id::int8,
  scr.shipping_country_rate_id::int8

FROM public.shipping s
		
LEFT JOIN (SELECT 	id AS shipping_transfer_id,
					concat(transfer_type, ':', transfer_model) AS shipping_transfer_description
  	   		FROM public.shipping_transfer) AS st
ON s.shipping_transfer_description=st.shipping_transfer_description

LEFT JOIN (SELECT 	agreement_id AS shipping_agreement_id,
	   				concat(agreement_id, ':', agreement_number, ':', agreement_rate, ':', agreement_commission) AS vendor_agreement_description
	   		FROM public.shipping_agreement) AS sa 
ON s.vendor_agreement_description=sa.vendor_agreement_description
LEFT JOIN (SELECT 	id AS shipping_country_rate_id,
	   				shipping_country
	  		 FROM public.shipping_country_rates) AS scr 
ON s.shipping_country=scr.shipping_country;