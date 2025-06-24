import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

export function ClientDetailClientComponent({ id }: { id: string }) {
  const router = useRouter()
  const { data: client } = useQuery({
    queryKey: ['client', id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('clients')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error
      return data
    },
  })
  if (!client) return null
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Détails du client</h1>
        <div className="flex gap-2">
          <Button
            variant="outline"
            onClick={() => router.push(`/clients/${id}/edit`)}
          >
            Modifier
          </Button>
          <Button variant="outline" onClick={() => router.push('/clients')}>
            Retour
          </Button>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            {client.full_name}
            <Badge variant="outline">Client</Badge>
          </CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2">
            <h3 className="font-medium">Coordonnées</h3>
            <p>{client.email}</p>
            <p>{client.phone}</p>
          </div>
          <div className="space-y-2">
            <h3 className="font-medium">Adresse</h3>
            <p>{client.address}</p>
            <p>
              {client.postal_code} {client.city}
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
