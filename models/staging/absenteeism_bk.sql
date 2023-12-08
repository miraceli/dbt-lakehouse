SELECT
  cg.name as GRUPO,
  cp.name as EMPRESA,
  ct.name as CARETEAM,
  (SELECT 
    COUNT(pt.id)
    FROM public.appGH_patient as pt
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = pt.id
    WHERE ptct.careteam_id = ct.id and pt.is_active ='true') as pacientes_ativos,
  (SELECT 
    COUNT(pt.id)
    FROM public.appGH_patient as pt
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = pt.id
    WHERE ptct.careteam_id = ct.id and pt.is_active ='false') as pacientes_inativos,
  GREATEST(
    (SELECT MAX(ate.date)
     FROM public.appDocs_medicalcertificate as ate
     LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = ate.patient_id_id
     WHERE ptct.careteam_id = ct.id),
    (SELECT MAX(atex.date)
     FROM public.appDocs_externalsystemmedicalcertificate as atex
     LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = atex.patient_id_id
     WHERE ptct.careteam_id = ct.id)
  ) as ultima_data,
  (SELECT 
    COUNT(pt.id)
    FROM public.appGH_patient as pt
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = pt.id
    WHERE ptct.careteam_id = ct.id) as pacientes_totais,
  (SELECT 
    COUNT(ate.id)
    FROM public.appDocs_medicalcertificate as ate
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = ate.patient_id_id
    WHERE ptct.careteam_id = ct.id) as atestados_internos,
  (SELECT 
    COUNT(atex.id)
    FROM public.appDocs_externalsystemmedicalcertificate as atex
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = atex.patient_id_id
    WHERE ptct.careteam_id = ct.id) as atestados_externos,
  (
	(SELECT 
    COUNT(ate.id)
    FROM public.appDocs_medicalcertificate as ate
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = ate.patient_id_id
    WHERE ptct.careteam_id = ct.id) + (SELECT 
    COUNT(atex.id)
    FROM public.appDocs_externalsystemmedicalcertificate as atex
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = atex.patient_id_id
    WHERE ptct.careteam_id = ct.id)
  ) as total_atestados,
  CASE
    WHEN 
		(
		SELECT 
		COUNT(pt.id)
		FROM public.appGH_patient as pt
		LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = pt.id
		WHERE ptct.careteam_id = ct.id and pt.is_active ='true'
		) > 0
    THEN(
        (
	(SELECT 
    COUNT(ate.id)
    FROM public.appDocs_medicalcertificate as ate
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = ate.patient_id_id
    WHERE ptct.careteam_id = ct.id) + (SELECT 
    COUNT(atex.id)
    FROM public.appDocs_externalsystemmedicalcertificate as atex
    LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = atex.patient_id_id
    WHERE ptct.careteam_id = ct.id)
  )
        /
        (
        SELECT COUNT(pt.id)::numeric
        FROM public.appGH_patient as pt
        LEFT JOIN public.appGH_patient_careteam_id as ptct on ptct.patient_id = pt.id
        WHERE ptct.careteam_id = ct.id and pt.is_active ='true'
        )::numeric
	)
    ELSE 0
  END as Frequencia
FROM 
  public.appgh_companygroup as cg
LEFT JOIN
  public.appGH_company as cp on cp.company_group_id_id = cg.id
LEFT JOIN
  public.appGH_careteam as ct on ct.company_id_id = cp.id
GROUP BY
  cg.name,
  cp.name,
  ct.name,
  ct.id
ORDER BY
  cg.name
