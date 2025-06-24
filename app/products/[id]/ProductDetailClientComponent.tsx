import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

export function ProductDetailClientComponent({ id }: { id: string }) {
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
  const priceWithTax = product.price * (1 + product.tax_rate / 100)
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Détails du produit</h1>
        <div className="flex gap-2">
          <Button
            variant="outline"
            onClick={() => router.push(`/products/${id}/edit`)}
          >
            Modifier
          </Button>
          <Button variant="outline" onClick={() => router.push('/products')}>
            Retour
          </Button>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            {product.name}
            <Badge variant="outline">Réf: {product.reference}</Badge>
          </CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <div className="space-y-4">
            <div className="space-y-2">
              <h3 className="font-medium">Prix</h3>
              <p>
                <span className="font-medium">HT:</span> {product.price.toFixed(2)} MAD
              </p>
              <p>
                <span className="font-medium">TVA ({product.tax_rate}%):</span>{' '}
                {(product.price * (product.tax_rate / 100)).toFixed(2)} MAD
              </p>
              <p>
                <span className="font-medium">TTC:</span> {priceWithTax.toFixed(2)} MAD
              </p>
            </div>
            <div className="space-y-2">
              <h3 className="font-medium">Stock</h3>
              <p>{product.stock} unités disponibles</p>
            </div>
          </div>
          <div className="space-y-2">
            <h3 className="font-medium">Description</h3>
            <p className="text-muted-foreground">
              {product.description || 'Aucune description disponible'}
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
