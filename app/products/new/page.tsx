'use client'

import ProductForm from '@/app/products/components/product-form'
import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'

export default function NewProductPage() {
  const router = useRouter()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Nouveau produit</h1>
        <Button variant="outline" onClick={() => router.push('/products')}>
          Retour
        </Button>
      </div>
      <ProductForm />
    </div>
  )
}
