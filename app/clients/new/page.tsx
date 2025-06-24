'use client'

import ClientForm from '@/app/clients/components/client-form'
import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'

export default function NewClientPage() {
  const router = useRouter()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Nouveau client</h1>
        <Button variant="outline" onClick={() => router.push('/clients')}>
          Retour
        </Button>
      </div>
      <ClientForm />
    </div>
  )
}
