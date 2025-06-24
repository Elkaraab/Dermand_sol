/*
# Schéma initial pour Dermand Solution

1. Nouvelles Tables
  - `clients`: Stocke les informations des clients
  - `products`: Catalogue des produits de menuiserie
  - `quotes`: Devis générés pour les clients
  - `invoice`: Factures générées
  - `quote_items`: Articles inclus dans les devis
  - `invoice_items`: Articles inclus dans les factures

2. Sécurité
  - Activation RLS pour toutes les tables
  - Politiques pour accès authentifié seulement
  - Restrictions par utilisateur
*/

-- Table clients
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  postal_code TEXT,
  country TEXT DEFAULT 'Maroc',
  tax_id TEXT,
  notes TEXT,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table produits
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  unit TEXT NOT NULL DEFAULT 'm²',
  material TEXT,
  color TEXT,
  thickness TEXT,
  glazing TEXT,
  hardware_included BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table devis
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_number TEXT NOT NULL UNIQUE,
  client_id UUID REFERENCES clients NOT NULL,
  client_name TEXT NOT NULL,
  client_address TEXT,
  client_tax_id TEXT,
  date DATE NOT NULL DEFAULT NOW(),
  validity_days INTEGER NOT NULL DEFAULT 30,
  status TEXT NOT NULL DEFAULT 'draft',
  notes TEXT,
  subtotal DECIMAL(10,2) NOT NULL,
  tax_rate DECIMAL(5,2) NOT NULL DEFAULT 20.00,
  tax_amount DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table articles devis
CREATE TABLE quote_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_id UUID REFERENCES quotes ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products,
  description TEXT NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit TEXT NOT NULL DEFAULT 'm²',
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table factures
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number TEXT NOT NULL UNIQUE,
  quote_id UUID REFERENCES quotes,
  client_id UUID REFERENCES clients NOT NULL,
  client_name TEXT NOT NULL,
  client_address TEXT,
  client_tax_id TEXT,
  date DATE NOT NULL DEFAULT NOW(),
  due_date DATE NOT NULL DEFAULT (NOW() + INTERVAL '30 days'),
  status TEXT NOT NULL DEFAULT 'unpaid',
  payment_method TEXT,
  payment_reference TEXT,
  notes TEXT,
  subtotal DECIMAL(10,2) NOT NULL,
  tax_rate DECIMAL(5,2) NOT NULL DEFAULT 20.00,
  tax_amount DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table articles facture
CREATE TABLE invoice_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID REFERENCES invoices ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products,
  description TEXT NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit TEXT NOT NULL DEFAULT 'm²',
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Fonction pour les timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour les timestamps
CREATE TRIGGER update_clients_updated_at
BEFORE UPDATE ON clients
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_quotes_updated_at
BEFORE UPDATE ON quotes
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_invoices_updated_at
BEFORE UPDATE ON invoices
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Fonction pour générer les numéros de devis
CREATE OR REPLACE FUNCTION generate_quote_number()
RETURNS TEXT AS $$
DECLARE
  next_num INTEGER;
  year_text TEXT;
  quote_num TEXT;
BEGIN
  year_text := TO_CHAR(NOW(), 'YYYY');
  SELECT COALESCE(MAX(SUBSTRING(quote_number FROM 5 FOR 6)::INTEGER, 0) + 1 
  INTO next_num
  FROM quotes
  WHERE SUBSTRING(quote_number FROM 1 FOR 4) = year_text;
  
  quote_num := year_text || LPAD(next_num::TEXT, 6, '0');
  RETURN quote_num;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer les numéros de facture
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
  next_num INTEGER;
  year_text TEXT;
  invoice_num TEXT;
BEGIN
  year_text := TO_CHAR(NOW(), 'YYYY');
  SELECT COALESCE(MAX(SUBSTRING(invoice_number FROM 5 FOR 6)::INTEGER, 0) + 1 
  INTO next_num
  FROM invoices
  WHERE SUBSTRING(invoice_number FROM 1 FOR 4) = year_text;
  
  invoice_num := year_text || LPAD(next_num::TEXT, 6, '0');
  RETURN invoice_num;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour les statistiques dashboard
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
      ELSE (COUNT(*) FILTER (WHERE status = 'converted')::FLOAT / COUNT(*)::FLOAT * 100
    END
  ) INTO result
  FROM quotes
  WHERE created_by = user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Activer RLS pour toutes les tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quote_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;

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

-- Créer un type pour les résultats de recherche
CREATE TYPE search_result AS (
  id UUID,
  type TEXT,
  name TEXT,
  description TEXT,
  date TIMESTAMPTZ,
  amount DECIMAL(10,2),
  status TEXT
);

-- Fonction de recherche globale
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
