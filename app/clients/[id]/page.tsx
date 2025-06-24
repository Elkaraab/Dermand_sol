import dynamic from 'next/dynamic'

const ClientDetailClientComponent = dynamic(() => import('./components/ClientDetailClientComponent').then(mod => mod.ClientDetailClientComponent), { ssr: false })

export default function ClientDetailPage({ params }: { params: { id: string } }) {
  return <ClientDetailClientComponent id={params.id} />
}
