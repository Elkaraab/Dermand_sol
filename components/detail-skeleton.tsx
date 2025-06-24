import { Skeleton } from '@/components/ui/skeleton'

interface DetailSkeletonProps {
  cardCount?: number
  itemCount?: number
}

export function DetailSkeleton({ 
  cardCount = 2, 
  itemCount = 4 
}: DetailSkeletonProps) {
  return (
    <div className="space-y-4">
      <Skeleton className="h-10 w-1/3" />
      <div className="grid gap-4 md:grid-cols-2">
        {Array.from({ length: cardCount }).map((_, i) => (
          <div key={i} className="space-y-4">
            {Array.from({ length: itemCount }).map((_, j) => (
              <Skeleton key={j} className="h-20" />
            ))}
          </div>
        ))}
      </div>
    </div>
  )
}
