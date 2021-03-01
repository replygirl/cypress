import Debug from 'debug'

import { ErrorMiddleware } from '@packages/proxy'
import { CyHttpMessages } from '../types'
import _ from 'lodash'
import errors from '@packages/server/lib/errors'

const debug = Debug('cypress:net-stubbing:server:intercept-error')

export const InterceptError: ErrorMiddleware = function () {
  const backendRequest = this.netStubbingState.requests[this.req.requestId]

  if (!backendRequest) {
    // the original request was not intercepted, nothing to do
    return this.next()
  }

  debug('intercepting error %o', { req: this.req, backendRequest })

  backendRequest.continueResponse = this.next

  backendRequest.handleSubscriptions<CyHttpMessages.ResponseComplete>({
    eventName: 'after:response',
    data: {
      error: errors.clone(this.error),
    },
    mergeChanges: _.identity,
  })

  this.next()
}
