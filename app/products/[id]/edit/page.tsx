import dynamic from 'next/dynamic'

const EditProductClientComponent = dynamic(() => import('./EditProductClientComponent').then(mod => mod.EditProductClientComponent), { ssr: false })

export default function EditProductPage({ params }: { params: { id: string } }) {
  return <EditProductClientComponent id={params.id} />
}
