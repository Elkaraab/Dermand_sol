/*
# Schéma initial corrigé pour Dermand Solution

Corrections apportées :
- Fix de la fonction get_dashboard_stats (parenthèse manquante)
*/

[Le reste du schéma reste identique jusqu'à la fonction get_dashboard_stats]

-- Fonction corrigée pour les statistiques dashboard
CREATE OR REPLACE FUNCTION get_dashboard_stats(user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'quotes_this_month', COUNT(*) FILTER (WHERE date_trunc('month', created_at) = date_trunc('month', NOW())),
    'active_clients', COUNT(DISTINCT client_id) FILTER (WHERE created_at > NOW() - INTERVAL '6 months'),
    'revenue', COALESCE(SUM(total_amount) FILTER (WHERE status = 'paid' AND created_at > NOW() - INTERVAL '1 month'), 0),
    'conversion_rate', CASE 
      WHEN COUNT(*) FILTER (WHERE status = 'converted') = 0 THEN 0
      ELSE (COUNT(*) FILTER (WHERE status = 'converted')::FLOAT / COUNT(*)::FLOAT) * 100
    END
  ) INTO result
  FROM quotes
  WHERE created_by = user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

[Le reste du schéma reste inchangé]
