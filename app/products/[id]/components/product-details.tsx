'use client'

import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { DetailCard } from '@/components/detail-card'
import { DetailSkeleton } from '@/components/detail-skeleton'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

export default function ProductDetails({ productId }: { productId: string }) {
  const { data: product, isLoading } = useQuery({
    queryKey: ['product', productId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('id', productId)
        .single()

      if (error) throw error
      return data
    },
  })

  if (isLoading) return <DetailSkeleton />

  if (!product) return <div>Produit non trouvé</div>

  return (
    <div className="grid gap-4 md:grid-cols-2">
      <DetailCard
        title="Détails du produit"
        items={[
          { label: 'Référence', value: product.reference },
          { label: 'Nom', value: product.name },
          { label: 'Description', value: product.description },
        ]}
      />

      <DetailCard
        title="Prix et stock"
        items={[
          { label: 'Prix unitaire (HT)', value: `${product.price.toFixed(2)} MAD` },
          { label: 'TVA', value: `${product.tax_rate}%` },
          { 
            label: 'Prix unitaire (TTC)', 
            value: `${(product.price * (1 + product.tax_rate / 100)).toFixed(2)} MAD` 
          },
          { label: 'Stock disponible', value: product.stock },
        ]}
      />

      <DetailCard
        title="Dates"
        items={[
          { 
            label: 'Date de création', 
            value: format(new Date(product.created_at), 'PPP', { locale: fr })
          },
        ]}
      />
    </div>
  )
}
