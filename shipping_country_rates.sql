DROP TABLE IF EXISTS public.shipping_country_rates;
--DROP SEQUENCE IF EXISTS shipping_country_sequence;

CREATE TABLE public.shipping_country_rates(
  id BIGINT NOT NULL PRIMARY KEY,
  shipping_country text NULL,
  shipping_country_base_rate numeric(14, 3) NULL
  );

CREATE SEQUENCE shipping_country_sequence
START 1;

INSERT INTO public.shipping_country_rates (id, shipping_country, shipping_country_base_rate)
SELECT nextval('shipping_country_sequence')::BIGINT AS id,
       shipping_country,
       shipping_country_base_rate
FROM
  (SELECT DISTINCT shipping_country,
                   shipping_country_base_rate
   FROM public.shipping s) AS shipping_information;

DROP SEQUENCE shipping_country_sequence;
SELECT *
FROM public.shipping_country_rates
LIMIT 10;
