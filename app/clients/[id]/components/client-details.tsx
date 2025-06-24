'use client'

import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { DetailCard } from '@/components/detail-card'
import { DetailSkeleton } from '@/components/detail-skeleton'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

export default function ClientDetails({ clientId }: { clientId: string }) {
  const { data: client, isLoading } = useQuery({
    queryKey: ['client', clientId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('clients')
        .select('*')
        .eq('id', clientId)
        .single()

      if (error) throw error
      return data
    },
  })

  if (isLoading) return <DetailSkeleton />

  if (!client) return <div>Client non trouvé</div>

  return (
    <div className="grid gap-4 md:grid-cols-2">
      <DetailCard
        title="Informations générales"
        items={[
          { label: 'Nom complet', value: client.full_name },
          { label: 'Email', value: client.email },
          { label: 'Téléphone', value: client.phone },
        ]}
      />

      <DetailCard
        title="Adresse"
        items={[
          { label: 'Adresse', value: client.address },
          { label: 'Ville', value: client.city },
          { label: 'Code postal', value: client.postal_code },
        ]}
      />

      <DetailCard
        title="Dates"
        items={[
          { 
            label: 'Date de création', 
            value: format(new Date(client.created_at), 'PPP', { locale: fr })
          },
        ]}
      />
    </div>
  )
}
