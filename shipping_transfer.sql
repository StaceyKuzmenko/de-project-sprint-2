DROP TABLE IF EXISTS public.shipping_transfer;
--DROP SEQUENCE IF EXISTS shipping_transfer_sequence;

CREATE TABLE public.shipping_transfer(
  id BIGINT NOT NULL PRIMARY KEY,
  transfer_type varchar(2) NOT NULL,
  transfer_model varchar(9) NOT NULL,
  shipping_transfer_rate numeric(14, 3) NOT NULL
  );

CREATE SEQUENCE shipping_transfer_sequence
START 1;

INSERT INTO public.shipping_transfer (id, transfer_type, transfer_model, shipping_transfer_rate)
SELECT DISTINCT
  nextval('shipping_transfer_sequence')::BIGINT as id,
  split_part(shipping_transfer_description, ':', 1)::varchar(2) as transfer_type,
  split_part(shipping_transfer_description, ':', 2)::varchar(9) as transfer_model,
  shipping_transfer_rate
FROM public.shipping
GROUP BY transfer_type, transfer_model, shipping_transfer_rate;

DROP SEQUENCE shipping_transfer_sequence;

