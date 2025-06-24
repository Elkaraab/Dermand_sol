import dynamic from 'next/dynamic'

const EditClientClientComponent = dynamic(() => import('./EditClientClientComponent').then(mod => mod.EditClientClientComponent), { ssr: false })

export default function EditClientPage({ params }: { params: { id: string } }) {
  return <EditClientClientComponent id={params.id} />
}
