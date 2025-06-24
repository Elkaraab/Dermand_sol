'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { toast } from '@/hooks/use-toast'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase/client'

const productFormSchema = z.object({
  reference: z.string().min(2, {
    message: 'La référence doit contenir au moins 2 caractères.',
  }),
  name: z.string().min(2, {
    message: 'Le nom doit contenir au moins 2 caractères.',
  }),
  description: z.string().optional(),
  price: z.coerce.number().min(0.01, {
    message: 'Le prix doit être supérieur à 0.',
  }),
  tax_rate: z.coerce.number().min(0).max(100, {
    message: 'Le taux de TVA doit être entre 0 et 100%.',
  }),
  stock: z.coerce.number().min(0, {
    message: 'Le stock ne peut pas être négatif.',
  }),
})

type ProductFormValues = z.infer<typeof productFormSchema>

interface ProductFormProps {
  initialData?: ProductFormValues
  productId?: string
}

export default function ProductForm({ initialData, productId }: ProductFormProps) {
  const router = useRouter()
  const form = useForm<ProductFormValues>({
    resolver: zodResolver(productFormSchema),
    defaultValues: initialData || {
      reference: '',
      name: '',
      description: '',
      price: 0,
      tax_rate: 20, // Default Moroccan VAT rate
      stock: 0,
    },
  })

  const onSubmit = async (data: ProductFormValues) => {
    try {
      if (productId) {
        // Update existing product
        const { error } = await supabase
          .from('products')
          .update(data)
          .eq('id', productId)

        if (error) throw error
        toast({
          title: 'Produit mis à jour avec succès',
        })
      } else {
        // Create new product
        const { error } = await supabase.from('products').insert(data)

        if (error) throw error
        toast({
          title: 'Produit créé avec succès',
        })
      }
      router.refresh()
      router.push('/products')
    } catch (error) {
      toast({
        title: 'Erreur',
        description: 'Une erreur est survenue',
        variant: 'destructive',
      })
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <div className="grid gap-4 md:grid-cols-2">
          <FormField
            control={form.control}
            name="reference"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Référence</FormLabel>
                <FormControl>
                  <Input placeholder="Référence du produit" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Nom</FormLabel>
                <FormControl>
                  <Input placeholder="Nom du produit" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="price"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Prix unitaire (HT)</FormLabel>
                <FormControl>
                  <Input type="number" placeholder="Prix" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="tax_rate"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Taux de TVA (%)</FormLabel>
                <FormControl>
                  <Input type="number" placeholder="TVA" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="stock"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Stock disponible</FormLabel>
                <FormControl>
                  <Input type="number" placeholder="Stock" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem className="md:col-span-2">
                <FormLabel>Description</FormLabel>
                <FormControl>
                  <Textarea
                    placeholder="Description du produit"
                    className="min-h-[100px]"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        <div className="flex justify-end gap-4">
          <Button
            type="button"
            variant="outline"
            onClick={() => router.push('/products')}
          >
            Annuler
          </Button>
          <Button type="submit">
            {productId ? 'Mettre à jour' : 'Créer'}
          </Button>
        </div>
      </form>
    </Form>
  )
}
