import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import ProductForm from '@/app/products/components/product-form'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'

export function EditProductClientComponent({ id }: { id: string }) {
  const router = useRouter()
  const { data: product } = useQuery({
    queryKey: ['product', id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error
      return data
    },
  })
  if (!product) return null
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Modifier produit</h1>
        <Button variant="outline" onClick={() => router.push('/products')}>
          Retour
        </Button>
      </div>
      <ProductForm initialData={product} productId={id} />
    </div>
  )
}
