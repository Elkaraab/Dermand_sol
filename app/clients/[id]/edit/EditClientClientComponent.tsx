import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import ClientForm from '@/app/clients/components/client-form'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'

export function EditClientClientComponent({ id }: { id: string }) {
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
        <h1 className="text-2xl font-bold">Modifier client</h1>
        <Button variant="outline" onClick={() => router.push('/clients')}>
          Retour
        </Button>
      </div>
      <ClientForm initialData={client} clientId={id} />
    </div>
  )
}
