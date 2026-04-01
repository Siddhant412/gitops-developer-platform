import { useEffect, useState } from 'react';
import { Button } from '@material-ui/core';
import {
  EmptyState,
  InfoCard,
  Link,
  Progress,
  ResponseErrorPanel,
  Table,
  TableColumn,
} from '@backstage/core-components';
import {
  discoveryApiRef,
  fetchApiRef,
  useApi,
} from '@backstage/core-plugin-api';
import { useEntity } from '@backstage/plugin-catalog-react';

type WorkflowRun = {
  id: number;
  name?: string | null;
  display_title?: string | null;
  head_branch?: string | null;
  head_sha?: string | null;
  event?: string | null;
  status?: string | null;
  conclusion?: string | null;
  updated_at?: string | null;
  html_url: string;
  run_number?: number | null;
};

type WorkflowRunsResponse = {
  workflow_runs: WorkflowRun[];
};

type WorkflowRunRow = {
  workflow: string;
  branch: string;
  event: string;
  status: string;
  updated: string;
  commit: string;
  htmlUrl: string;
};

const columns: TableColumn<WorkflowRunRow>[] = [
  {
    title: 'Workflow',
    field: 'workflow',
    render: row => (
      <Link to={row.htmlUrl} target="_blank" rel="noopener noreferrer">
        {row.workflow}
      </Link>
    ),
  },
  { title: 'Branch', field: 'branch' },
  { title: 'Event', field: 'event' },
  { title: 'Status', field: 'status' },
  { title: 'Updated', field: 'updated' },
  { title: 'Commit', field: 'commit' },
];

function formatTimestamp(value?: string | null): string {
  if (!value) {
    return 'Unknown';
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return date.toLocaleString();
}

function summarizeStatus(run: WorkflowRun): string {
  if (run.conclusion) {
    return run.status ? `${run.status} / ${run.conclusion}` : run.conclusion;
  }

  return run.status ?? 'unknown';
}

function summarizeWorkflow(run: WorkflowRun): string {
  return run.name ?? run.display_title ?? `Run #${run.run_number ?? run.id}`;
}

export const EntityGithubActionsContent = () => {
  const { entity } = useEntity();
  const discoveryApi = useApi(discoveryApiRef);
  const fetchApi = useApi(fetchApiRef);
  const projectSlug =
    entity.metadata.annotations?.['github.com/project-slug'] ?? '';

  const [rows, setRows] = useState<WorkflowRunRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | undefined>(undefined);

  useEffect(() => {
    let cancelled = false;

    async function loadWorkflowRuns() {
      if (!projectSlug) {
        setRows([]);
        setLoading(false);
        return;
      }

      const [owner, repo] = projectSlug.split('/');
      if (!owner || !repo) {
        setError(
          new Error(
            `Invalid github.com/project-slug annotation '${projectSlug}'. Expected 'owner/repo'.`,
          ),
        );
        setLoading(false);
        return;
      }

      setLoading(true);
      setError(undefined);

      try {
        const proxyBaseUrl = await discoveryApi.getBaseUrl('proxy');
        const response = await fetchApi.fetch(
          `${proxyBaseUrl}/github-api/repos/${owner}/${repo}/actions/runs?per_page=10`,
        );

        if (!response.ok) {
          const body = await response.text();
          throw new Error(
            `GitHub Actions request failed with ${response.status} ${response.statusText}${
              body ? `: ${body}` : ''
            }`,
          );
        }

        const payload = (await response.json()) as WorkflowRunsResponse;
        const nextRows = payload.workflow_runs.map(run => ({
          workflow: summarizeWorkflow(run),
          branch: run.head_branch ?? 'Unknown',
          event: run.event ?? 'Unknown',
          status: summarizeStatus(run),
          updated: formatTimestamp(run.updated_at),
          commit: run.head_sha?.slice(0, 7) ?? 'Unknown',
          htmlUrl: run.html_url,
        }));

        if (!cancelled) {
          setRows(nextRows);
        }
      } catch (nextError) {
        if (!cancelled) {
          setError(
            nextError instanceof Error
              ? nextError
              : new Error('Failed to load GitHub Actions runs'),
          );
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    loadWorkflowRuns();

    return () => {
      cancelled = true;
    };
  }, [discoveryApi, fetchApi, projectSlug]);

  if (!projectSlug) {
    return (
      <EmptyState
        title="No GitHub repository linked"
        missing="info"
        description="Add the github.com/project-slug annotation to show workflow runs on this page."
      />
    );
  }

  return (
    <InfoCard
      title="GitHub Actions"
      action={
        <Button
          color="primary"
          href={`https://github.com/${projectSlug}/actions`}
          target="_blank"
          rel="noopener noreferrer"
        >
          Open in GitHub
        </Button>
      }
    >
      {loading ? <Progress /> : null}
      {error ? <ResponseErrorPanel error={error} /> : null}
      {!loading && !error ? (
        rows.length > 0 ? (
          <Table
            title=""
            options={{
              paging: false,
              search: false,
              toolbar: false,
              padding: 'dense',
            }}
            columns={columns}
            data={rows}
          />
        ) : (
          <EmptyState
            title="No workflow runs found"
            missing="data"
            description="GitHub did not return any workflow runs for this repository yet."
          />
        )
      ) : null}
    </InfoCard>
  );
};
