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
import { toast } from '@/hooks/use-toast'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase/client'

const clientFormSchema = z.object({
  full_name: z.string().min(2, {
    message: 'Le nom doit contenir au moins 2 caractères.',
  }),
  email: z.string().email({
    message: 'Veuillez entrer une adresse email valide.',
  }),
  phone: z.string().min(10, {
    message: 'Le numéro de téléphone doit contenir au moins 10 chiffres.',
  }),
  address: z.string().min(5, {
    message: 'L\'adresse doit contenir au moins 5 caractères.',
  }),
  city: z.string().min(2, {
    message: 'La ville doit contenir au moins 2 caractères.',
  }),
  postal_code: z.string().min(4, {
    message: 'Le code postal doit contenir au moins 4 chiffres.',
  }),
})

type ClientFormValues = z.infer<typeof clientFormSchema>

interface ClientFormProps {
  initialData?: ClientFormValues
  clientId?: string
}

export default function ClientForm({ initialData, clientId }: ClientFormProps) {
  const router = useRouter()
  const form = useForm<ClientFormValues>({
    resolver: zodResolver(clientFormSchema),
    defaultValues: initialData || {
      full_name: '',
      email: '',
      phone: '',
      address: '',
      city: '',
      postal_code: '',
    },
  })

  const onSubmit = async (data: ClientFormValues) => {
    try {
      if (clientId) {
        // Update existing client
        const { error } = await supabase
          .from('clients')
          .update(data)
          .eq('id', clientId)

        if (error) throw error
        toast({
          title: 'Client mis à jour avec succès',
        })
      } else {
        // Create new client
        const { error } = await supabase.from('clients').insert(data)

        if (error) throw error
        toast({
          title: 'Client créé avec succès',
        })
      }
      router.refresh()
      router.push('/clients')
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
            name="full_name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Nom complet</FormLabel>
                <FormControl>
                  <Input placeholder="Nom du client" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input placeholder="Email du client" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="phone"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Téléphone</FormLabel>
                <FormControl>
                  <Input placeholder="Numéro de téléphone" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="address"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Adresse</FormLabel>
                <FormControl>
                  <Input placeholder="Adresse complète" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="city"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Ville</FormLabel>
                <FormControl>
                  <Input placeholder="Ville" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="postal_code"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Code postal</FormLabel>
                <FormControl>
                  <Input placeholder="Code postal" {...field} />
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
            onClick={() => router.push('/clients')}
          >
            Annuler
          </Button>
          <Button type="submit">
            {clientId ? 'Mettre à jour' : 'Créer'}
          </Button>
        </div>
      </form>
    </Form>
  )
}
