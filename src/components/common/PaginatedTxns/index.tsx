import { type ReactElement, useEffect, useState, useMemo } from 'react'
import { Box, Typography } from '@mui/material'
import TxList from '@/components/transactions/TxList'
import ErrorMessage from '@/components/tx/ErrorMessage'
import useTxHistory from '@/hooks/useTxHistory'
import useTxQueue from '@/hooks/useTxQueue'
import PagePlaceholder from '../PagePlaceholder'
import InfiniteScroll from '../InfiniteScroll'
import SkeletonTxList from './SkeletonTxList'
import BatchExecuteButton from '@/components/transactions/BatchExecuteButton'
import TxFilterButton from '@/components/transactions/TxFilterButton'
import { TxFilter, useTxFilter } from '@/utils/tx-history-filter'
import { isHasNextConflictTransactionListItem, isTransactionListItem } from '@/utils/transaction-guards'
import type { TransactionListPage } from '@gnosis.pm/safe-react-gateway-sdk'
import { BatchExecuteHoverProvider } from '@/components/transactions/BatchExecuteButton/BatchExecuteHoverProvider'
import { adjustDateLabelsTimezone } from '@/utils/transactions'

const NoQueuedTxns = () => (
  <Box mt="5vh">
    <PagePlaceholder imageUrl="/images/no-transactions.svg" text="Queued transactions will appear here" />
  </Box>
)

const getResultCount = (filter: TxFilter, page: TransactionListPage) => {
  const count = page.results.filter(isTransactionListItem).length

  return `${page.next ? '> ' : ''}${count} ${filter.type} transactions found`.toLowerCase()
}

const TxPage = ({
  pageUrl,
  useTxns,
  onNextPage,
  isFirstPage,
}: {
  pageUrl: string
  useTxns: typeof useTxHistory | typeof useTxQueue
  onNextPage?: (pageUrl?: string) => void
  isFirstPage: boolean
}): ReactElement => {
  const { page, error } = useTxns(pageUrl)
  const [filter] = useTxFilter()

  const isQueue = useTxns === useTxQueue

  useEffect(() => {
    // If conflict transactions split across pages, we must fetch the next page
    const lastItem = page?.results[page.results.length - 1]
    const hasSplitConflict = lastItem && isHasNextConflictTransactionListItem(lastItem)

    if (hasSplitConflict) {
      onNextPage?.(page?.next)
    }
  }, [onNextPage, page?.next, page?.results])

  const txListPageItems = useMemo(() => {
    if (!page?.results) {
      return
    }

    // Date labels are returned at start of UTC day. Users in UTC-n timezones would see "yesterday" for txs today
    return isQueue ? page.results : adjustDateLabelsTimezone(page.results)
  }, [isQueue, page?.results])

  if (page && txListPageItems) {
    return (
      <>
        {/* FIXME: batching will only work for the first page results */}
        {isFirstPage && (
          <Box display="flex" flexDirection="column" alignItems="flex-end" mt={['-94px', '-44px']} mb={['60px', 0]}>
            {isQueue ? <BatchExecuteButton items={txListPageItems} /> : <TxFilterButton />}
            {filter && <Typography mt={2}>{getResultCount(filter, page)}</Typography>}
          </Box>
        )}

        {page.results.length ? <TxList items={txListPageItems} /> : isQueue && <NoQueuedTxns />}

        {onNextPage && page.next && (
          <Box my={4} textAlign="center">
            <InfiniteScroll onLoadMore={() => onNextPage(page.next)} />
          </Box>
        )}
      </>
    )
  }

  if (error) {
    return <ErrorMessage>Error loading transactions</ErrorMessage>
  }

  return <SkeletonTxList />
}

const PaginatedTxns = ({ useTxns }: { useTxns: typeof useTxHistory | typeof useTxQueue }): ReactElement => {
  const [pages, setPages] = useState<string[]>([''])
  const [filter] = useTxFilter()

  useEffect(() => {
    setPages([''])
  }, [filter])

  const onNextPage = (pageUrl = '') => {
    setPages((prev) => [...prev, pageUrl])
  }

  return (
    <Box mb={4} position="relative">
      <BatchExecuteHoverProvider>
        {pages.map((pageUrl, index) => (
          <TxPage
            key={pageUrl}
            pageUrl={pageUrl}
            useTxns={useTxns}
            isFirstPage={index === 0}
            onNextPage={index === pages.length - 1 ? onNextPage : undefined}
          />
        ))}
      </BatchExecuteHoverProvider>
    </Box>
  )
}

export default PaginatedTxns
