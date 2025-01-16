import { useEffect, useState } from 'react';

import { useRouter } from 'next/router';

import { getQueryId } from '@/utils/common';
import { findLastLeafId, findSelectedMessageByLeafId } from '@/utils/message';

import { ChatStatus, IChat } from '@/types/chat';
import { IChatMessage } from '@/types/chatMessage';

import { ChatMessage } from '@/components/ChatMessage';
import PageNotFound from '@/components/PageNotFound/PageNotFound';

import { getAdminMessage } from '@/apis/adminApis';

export default function MessageDetails() {
  const router = useRouter();
  const [selectedChat, setSelectedChat] = useState<IChat | null>(null);
  const [messages, setMessages] = useState<IChatMessage[]>([]);
  const [selectedMessages, setSelectedMessages] = useState<IChatMessage[][]>(
    [],
  );
  const [loading, setLoading] = useState(true);

  const handleChangeChatLeafMessageId = (messageId: string) => {
    const leafId = findLastLeafId(messages, messageId);
    const selectedMsgs = findSelectedMessageByLeafId(messages, leafId);
    setSelectedMessages(selectedMsgs);
  };

  useEffect(() => {
    setLoading(true);
    if (!router.isReady) return;
    const chatShareId = getQueryId(router)!;
    getAdminMessage(chatShareId).then((data) => {
      setSelectedChat({ ...data, status: ChatStatus.None });
      setMessages(data.messages);
      const selectedMsgs = findSelectedMessageByLeafId(
        data.messages,
        data.leafMessageId!,
      );
      setSelectedMessages(selectedMsgs);
      setLoading(false);
    });
  }, [router.isReady]);

  const MessageRender = () => {
    return selectedChat ? (
      <>
        <ChatMessage
          selectedChat={selectedChat}
          selectedMessages={selectedMessages}
          messagesEndRef={null}
          readonly={true}
          onChangeChatLeafMessageId={handleChangeChatLeafMessageId}
        />
      </>
    ) : (
      <PageNotFound />
    );
  };

  return loading ? <></> : MessageRender();
}
