import dynamic from 'next/dynamic'

const ProductDetailClientComponent = dynamic(() => import('./ProductDetailClientComponent').then(mod => mod.ProductDetailClientComponent), { ssr: false })

export default function ProductDetailPage({ params }: { params: { id: string } }) {
  return <ProductDetailClientComponent id={params.id} />
}
