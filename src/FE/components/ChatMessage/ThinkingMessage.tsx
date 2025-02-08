import { useState } from 'react';

import useTranslation from '@/hooks/useTranslation';

import { preprocessLaTeX } from '@/utils/chats';

import { ChatSpanStatus, Content } from '@/types/chat';

import { CodeBlock } from '@/components/Markdown/CodeBlock';
import { MemoizedReactMarkdown } from '@/components/Markdown/MemoizedReactMarkdown';

import { IconChevronDown, IconChevronRight } from '../Icons';

import rehypeKatex from 'rehype-katex';
import remarkGfm from 'remark-gfm';
import remarkMath from 'remark-math';

export interface ResponseMessage {
  id: string;
  content: Content;
  status: ChatSpanStatus;
  spanId: number | null;
  reasoningDuration?: number;
}

interface Props {
  readonly?: boolean;
  message: ResponseMessage;
}

const ThinkingMessage = (props: Props) => {
  const { message } = props;
  const { t } = useTranslation();
  const { status: chatStatus, reasoningDuration } = message;

  const [isOpen, setIsOpen] = useState(true);
  return (
    <div className="mb-2">
      <div
        className="inline-flex items-center px-3 py-1 bg-gray-300 dark:bg-gray-700 text-sm gap-1 rounded-sm"
        onClick={() => {
          setIsOpen(!isOpen);
        }}
      >
        {chatStatus === ChatSpanStatus.Thinking
          ? t('Reasoning...')
          : t('Reasoning complete')}
        {isOpen ? (
          <IconChevronDown size={18} stroke="#6b7280" />
        ) : (
          <IconChevronRight size={18} stroke="#6b7280" />
        )}
      </div>
      {isOpen && (
        <div className="border-l-2 border-gray-200 ml-2 pl-2 text-gray-500 text-sm mt-2">
          <MemoizedReactMarkdown
            remarkPlugins={[remarkMath, remarkGfm]}
            rehypePlugins={[rehypeKatex as any]}
            components={{
              code({ node, className, inline, children, ...props }) {
                if (children.length) {
                  if (children[0] == '▍') {
                    return (
                      <span className="animate-pulse cursor-default mt-1">
                        ▍
                      </span>
                    );
                  }

                  children[0] = (children[0] as string).replace('`▍`', '▍');
                }

                const match = /language-(\w+)/.exec(className || '');

                return !inline ? (
                  <CodeBlock
                    key={Math.random()}
                    language={(match && match[1]) || ''}
                    value={String(children).replace(/\n$/, '')}
                    {...props}
                  />
                ) : (
                  <code className={className} {...props}>
                    {children}
                  </code>
                );
              },
              p({ children }) {
                return <p className="md-p">{children}</p>;
              },
              table({ children }) {
                return (
                  <table className="border-collapse border border-black px-3 py-1 dark:border-white">
                    {children}
                  </table>
                );
              },
              th({ children }) {
                return (
                  <th className="break-words border border-black bg-gray-500 px-3 py-1 text-white dark:border-white">
                    {children}
                  </th>
                );
              },
              td({ children }) {
                return (
                  <td className="break-words border border-black px-3 py-1 dark:border-white">
                    {children}
                  </td>
                );
              },
            }}
          >
            {`${preprocessLaTeX(message.content.think!)}${
              chatStatus === ChatSpanStatus.Thinking ? '`▍`' : ''
            }`}
          </MemoizedReactMarkdown>
        </div>
      )}
    </div>
  );
};

export default ThinkingMessage;
