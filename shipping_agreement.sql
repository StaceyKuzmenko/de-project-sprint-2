DROP 
  TABLE IF EXISTS public.shipping_agreement;
CREATE TABLE public.shipping_agreement(
  agreement_id BIGINT NOT NULL PRIMARY KEY, 
  agreement_number varchar(10) NOT NULL, 
  agreement_rate numeric(14, 2) NOT NULL, 
  agreement_commission numeric(14, 2) NOT NULL
);
INSERT INTO public.shipping_agreement (
  agreement_id, agreement_number, agreement_rate, 
  agreement_commission
) 
SELECT 
  DISTINCT split_part(
    vendor_agreement_description, ':', 
    1
  ):: BIGINT as agreement_id, 
  split_part(
    vendor_agreement_description, ':', 
    2
  ):: varchar(10) as agreement_number, 
  split_part(
    vendor_agreement_description, ':', 
    3
  ):: numeric(14, 2) as agreement_rate, 
  split_part(
    vendor_agreement_description, ':', 
    4
  ):: numeric(14, 2) as agreement_commission 
FROM 
  public.shipping;
SELECT *
FROM public.shipping_agreement
LIMIT 10;
