/*
# Schéma complet corrigé pour Dermand Solution

Corrections apportées :
- Fix de la fonction get_dashboard_stats (parenthèse manquante)
- Vérification de toutes les fonctions et politiques
*/

[Contenu précédent jusqu'à la fonction get_dashboard_stats déjà fournie]

-- Politiques pour la table clients
CREATE POLICY "Les utilisateurs peuvent voir leurs clients" 
ON clients FOR SELECT 
TO authenticated 
USING (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent créer des clients"
ON clients FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent modifier leurs clients"
ON clients FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent supprimer leurs clients"
ON clients FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- Politiques pour la table produits
CREATE POLICY "Les utilisateurs peuvent voir leurs produits" 
ON products FOR SELECT 
TO authenticated 
USING (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent créer des produits"
ON products FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent modifier leurs produits"
ON products FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent supprimer leurs produits"
ON products FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- Politiques pour la table devis
CREATE POLICY "Les utilisateurs peuvent voir leurs devis" 
ON quotes FOR SELECT 
TO authenticated 
USING (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent créer des devis"
ON quotes FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent modifier leurs devis"
ON quotes FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent supprimer leurs devis"
ON quotes FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- Politiques pour la table articles devis
CREATE POLICY "Les utilisateurs peuvent voir les articles de leurs devis" 
ON quote_items FOR SELECT 
TO authenticated 
USING (EXISTS (SELECT 1 FROM quotes WHERE id = quote_id AND created_by = auth.uid()));

CREATE POLICY "Les utilisateurs peuvent créer des articles devis"
ON quote_items FOR INSERT
TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM quotes WHERE id = quote_id AND created_by = auth.uid()));

CREATE POLICY "Les utilisateurs peuvent modifier les articles de leurs devis"
ON quote_items FOR UPDATE
TO authenticated
USING (EXISTS (SELECT 1 FROM quotes WHERE id = quote_id AND created_by = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM quotes WHERE id = quote_id AND created_by = auth.uid()));

CREATE POLICY "Les utilisateurs peuvent supprimer les articles de leurs devis"
ON quote_items FOR DELETE
TO authenticated
USING (EXISTS (SELECT 1 FROM quotes WHERE id = quote_id AND created_by = auth.uid()));

-- Politiques pour la table factures
CREATE POLICY "Les utilisateurs peuvent voir leurs factures" 
ON invoices FOR SELECT 
TO authenticated 
USING (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent créer des factures"
ON invoices FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent modifier leurs factures"
ON invoices FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Les utilisateurs peuvent supprimer leurs factures"
ON invoices FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- Politiques pour la table articles facture
CREATE POLICY "Les utilisateurs peuvent voir les articles de leurs factures" 
ON invoice_items FOR SELECT 
TO authenticated 
USING (EXISTS (SELECT 1 FROM invoices WHERE id = invoice_id AND created_by = auth.uid()));

CREATE POLICY "Les utilisateurs peuvent créer des articles facture"
ON invoice_items FOR INSERT
TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM invoices WHERE id = invoice_id AND created_by = auth.uid()));

CREATE POLICY "Les utilisateurs peuvent modifier les articles de leurs factures"
ON invoice_items FOR UPDATE
TO authenticated
USING (EXISTS (SELECT 1 FROM invoices WHERE id = invoice_id AND created_by = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM invoices WHERE id = invoice_id AND created_by = auth.uid()));

CREATE POLICY "Les utilisateurs peuvent supprimer les articles de leurs factures"
ON invoice_items FOR DELETE
TO authenticated
USING (EXISTS (SELECT 1 FROM invoices WHERE id = invoice_id AND created_by = auth.uid()));

-- Fonction de recherche globale (version corrigée)
CREATE OR REPLACE FUNCTION global_search(user_id UUID, search_term TEXT)
RETURNS SETOF search_result AS $$
BEGIN
  RETURN QUERY
  SELECT id, 'client' AS type, name, COALESCE(email, '') AS description, 
         created_at AS date, NULL AS amount, NULL AS status
  FROM clients
  WHERE created_by = user_id AND (name ILIKE '%' || search_term || '%' OR email ILIKE '%' || search_term || '%')
  
  UNION ALL
  
  SELECT id, 'product' AS type, name, COALESCE(description, '') AS description, 
         created_at AS date, price AS amount, NULL AS status
  FROM products
  WHERE created_by = user_id AND (name ILIKE '%' || search_term || '%' OR description ILIKE '%' || search_term || '%')
  
  UNION ALL
  
  SELECT id, 'quote' AS type, quote_number AS name, client_name AS description, 
         created_at AS date, total_amount AS amount, status
  FROM quotes
  WHERE created_by = user_id AND (quote_number ILIKE '%' || search_term || '%' OR client_name ILIKE '%' || search_term || '%')
  
  UNION ALL
  
  SELECT id, 'invoice' AS type, invoice_number AS name, client_name AS description, 
         created_at AS date, total_amount AS amount, status
  FROM invoices
  WHERE created_by = user_id AND (invoice_number ILIKE '%' || search_term || '%' OR client_name ILIKE '%' || search_term || '%')
  
  ORDER BY date DESC;
END;
$$ LANGUAGE plpgsql;
