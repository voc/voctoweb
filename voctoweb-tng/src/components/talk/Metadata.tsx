import { getRouteApi } from '@tanstack/react-router'
import { Calendar, Clock, ExternalLink, Eye, Upload } from 'lucide-react'
import { formatDate, formatDuration, formatViews } from '#/lib/format.ts'

const route = getRouteApi('/v/$slug')

export function Metadata() {
  const talk = route.useLoaderData()
  const eventDay = formatDate(talk.date ?? talk.releaseDate)
  const showRelease =
    talk.date &&
    talk.releaseDate &&
    formatDate(talk.date) !== formatDate(talk.releaseDate)

  return (
    <ul>
      <li>
        <Clock size={16} aria-hidden /> {formatDuration(talk.duration)}
      </li>
      {eventDay && (
        <li>
          <Calendar size={16} aria-hidden /> {eventDay}
        </li>
      )}
      {showRelease && (
        <li>
          <Upload size={16} aria-hidden /> released {formatDate(talk.releaseDate)}
        </li>
      )}
      <li>
        <Eye size={16} aria-hidden /> {formatViews(talk.viewCount)} views
      </li>
      {talk.link && (
        <li>
          <a href={talk.link}>
            <ExternalLink size={16} aria-hidden /> Fahrplan
          </a>
        </li>
      )}
      {talk.doi && (
        <li>
          <a href={`https://doi.org/${talk.doi}`}>
            <ExternalLink size={16} aria-hidden /> {talk.doi}
          </a>
        </li>
      )}
    </ul>
  )
}
