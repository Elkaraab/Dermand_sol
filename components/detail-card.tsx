import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

interface DetailCardProps {
  title: string
  items: {
    label: string
    value: string | number | React.ReactNode
    className?: string
  }[]
  className?: string
}

export function DetailCard({ title, items, className }: DetailCardProps) {
  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {items.map((item, index) => (
          <div key={index} className={item.className}>
            <p className="text-sm text-muted-foreground">{item.label}</p>
            <p className="mt-1">{item.value}</p>
          </div>
        ))}
      </CardContent>
    </Card>
  )
}
