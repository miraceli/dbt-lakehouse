WITH CareteamStats AS (
  SELECT
    ct.id as careteam_id,
    COUNT(CASE WHEN pt.is_active = 'true' THEN pt.id END) as pacientes_ativos,
    COUNT(CASE WHEN pt.is_active = 'false' THEN pt.id END) as pacientes_inativos,
    MAX(GREATEST(ate.date, atex.date)) as ultima_data,
    COUNT(pt.id) as pacientes_totais,
    COUNT(ate.id) as atestados_internos,
    COUNT(atex.id) as atestados_externos,
    COUNT(ate.id) + COUNT(atex.id) as total_atestados,
    CASE
      WHEN COUNT(pt.id) > 0
      THEN (COUNT(ate.id) + COUNT(atex.id))::numeric / COUNT(pt.id)::numeric
      ELSE 0
    END as Frequencia
  FROM public.appGH_careteam as ct
  LEFT JOIN public.appGH_company as cp ON ct.company_id_id = cp.id
  LEFT JOIN public.appgh_companygroup as cg ON cp.company_group_id_id = cg.id
  LEFT JOIN public.appGH_patient_careteam_id as ptct ON ptct.careteam_id = ct.id
  LEFT JOIN public.appGH_patient as pt ON ptct.patient_id = pt.id
  LEFT JOIN public.appDocs_medicalcertificate as ate ON ptct.patient_id = ate.patient_id_id
  LEFT JOIN public.appDocs_externalsystemmedicalcertificate as atex ON ptct.patient_id = atex.patient_id_id
  GROUP BY ct.id
),
FinalResult AS (
  SELECT
    cg.name as GRUPO,
    cp.name as EMPRESA,
    ct.name as CARETEAM,
    cs.pacientes_ativos,
    cs.pacientes_inativos,
    cs.ultima_data,
    cs.pacientes_totais,
    cs.atestados_internos,
    cs.atestados_externos,
    cs.total_atestados,
    cs.Frequencia
  FROM CareteamStats cs
  JOIN public.appGH_careteam as ct ON cs.careteam_id = ct.id
  LEFT JOIN public.appGH_company as cp ON ct.company_id_id = cp.id
  LEFT JOIN public.appgh_companygroup as cg ON cp.company_group_id_id = cg.id
)
SELECT * FROM FinalResult
ORDER BY GRUPO
