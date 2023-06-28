DROP TABLE IF EXISTS public.shipping_status;

CREATE TABLE public.shipping_status(
  shipping_id int8 NOT NULL PRIMARY KEY,
  status text NULL,
  state text NULL,
  shipping_start_fact_datetime timestamp NULL,
  shipping_end_fact_datetime timestamp NULL
  );

INSERT INTO public.shipping_status (shipping_id, status, state, shipping_start_fact_datetime, shipping_end_fact_datetime)
SELECT DISTINCT
  s.shippingid::int8 AS shipping_id,
  st.status::text,
  st.state::text,
  sfd.shipping_start_fact_datetime::timestamp,
  efd.shipping_end_fact_datetime::timestamp
FROM public.shipping s
LEFT JOIN (SELECT 	srt.shippingid as shipping_id,
					srt.status,
					srt.state
		FROM (SELECT DISTINCT 	shippingid,
			 					status,
								state,
		 						NTILE(7) OVER (PARTITION BY shippingid ORDER BY state_datetime DESC) AS sort
  			FROM public.shipping) as srt
			WHERE sort = 1
		  ) AS st
ON s.shippingid=st.shipping_id
LEFT JOIN (SELECT 	shippingid AS shipping_id,
		   			state_datetime AS shipping_start_fact_datetime
					--NTILE(1) OVER (ORDER BY state_datetime ASC) AS shipping_transfer_description
  	   	   FROM public.shipping
		   WHERE state = 'booked'
		  ) AS sfd
ON s.shippingid=sfd.shipping_id
LEFT JOIN (SELECT 	shippingid AS shipping_id,
		   			state_datetime AS shipping_end_fact_datetime
					--NTILE(1) OVER (ORDER BY state_datetime ASC) AS shipping_transfer_description
  	   	   FROM public.shipping
		   WHERE state = 'recieved'
		  ) AS efd
ON s.shippingid=efd.shipping_id;