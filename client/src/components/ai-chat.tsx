import { useState, useRef, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { MessageCircle, Send, Loader2, X, Minimize2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { queryClient, apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { useModule } from "@/contexts/ModuleContext";
import type { ChatMessage } from "@shared/schema";

export function AIChat() {
  const { toast } = useToast();
  const { activeModule } = useModule();
  const [isOpen, setIsOpen] = useState(false);
  const [isMinimized, setIsMinimized] = useState(false);
  const [message, setMessage] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Fetch conversation and messages
  const { data: conversationData, isLoading } = useQuery<{
    conversation: any | null;
    messages: ChatMessage[];
  }>({
    queryKey: ["/api/chat/conversation"],
    enabled: isOpen
  });

  // Send message mutation
  const sendMessageMutation = useMutation({
    mutationFn: async (userMessage: string) => {
      return apiRequest('POST', '/api/chat/message', {
        message: userMessage,
        module: activeModule
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/chat/conversation"] });
      setMessage("");
    },
    onError: (error: any) => {
      toast({
        title: "Erro ao enviar mensagem",
        description: error.message || "Não foi possível enviar a mensagem.",
        variant: "destructive"
      });
    }
  });

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim() || sendMessageMutation.isPending) return;
    sendMessageMutation.mutate(message.trim());
  };

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [conversationData?.messages]);

  // Safe access to messages array
  const messages = conversationData?.messages ?? [];

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-6 right-6 z-50 h-14 w-14 rounded-full bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-110 flex items-center justify-center group"
        data-testid="button-open-chat"
        aria-label="Abrir chat com IA"
      >
        <MessageCircle className="h-6 w-6 group-hover:scale-110 transition-transform" />
        <span className="absolute -top-1 -right-1 h-3 w-3 bg-green-500 rounded-full border-2 border-white animate-pulse"></span>
      </button>
    );
  }

  if (isMinimized) {
    return (
      <div className="fixed bottom-6 right-6 z-50">
        <button
          onClick={() => setIsMinimized(false)}
          className="h-14 px-6 rounded-full bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg hover:shadow-xl transition-all duration-300 flex items-center gap-2"
          data-testid="button-maximize-chat"
        >
          <MessageCircle className="h-5 w-5" />
          <span className="text-sm font-medium">Chat IA</span>
          {sendMessageMutation.isPending && (
            <Loader2 className="h-4 w-4 animate-spin" />
          )}
        </button>
      </div>
    );
  }

  return (
    <div className="fixed bottom-6 right-6 z-50 w-96 h-[600px] bg-white rounded-lg shadow-2xl flex flex-col overflow-hidden border border-gray-200">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <MessageCircle className="h-5 w-5" />
          <div>
            <h3 className="font-semibold text-sm">Assistente IA</h3>
            <p className="text-xs opacity-90">
              {activeModule === 'clean' ? 'OPUS Clean' : 'OPUS Manutenção'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={() => setIsMinimized(true)}
            className="p-1.5 hover:bg-white/20 rounded transition-colors"
            data-testid="button-minimize-chat"
            aria-label="Minimizar chat"
          >
            <Minimize2 className="h-4 w-4" />
          </button>
          <button
            onClick={() => setIsOpen(false)}
            className="p-1.5 hover:bg-white/20 rounded transition-colors"
            data-testid="button-close-chat"
            aria-label="Fechar chat"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
        {isLoading ? (
          <div className="flex items-center justify-center h-full">
            <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
          </div>
        ) : messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center px-4">
            <MessageCircle className="h-12 w-12 text-gray-300 mb-3" />
            <p className="text-gray-600 font-medium mb-1">Olá! Como posso ajudar?</p>
            <p className="text-sm text-gray-500">
              Pergunte sobre suas ordens de serviço, tarefas ou qualquer dúvida sobre o sistema.
            </p>
          </div>
        ) : (
          <>
            {messages.map((msg) => (
              <div
                key={msg.id}
                className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                data-testid={`message-${msg.role}-${msg.id}`}
              >
                <div
                  className={`max-w-[80%] rounded-lg px-4 py-2 ${
                    msg.role === 'user'
                      ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white'
                      : 'bg-white text-gray-900 border border-gray-200 shadow-sm'
                  }`}
                >
                  <p className="text-sm whitespace-pre-wrap">{msg.content}</p>
                  {msg.error && (
                    <p className="text-xs mt-1 opacity-75">⚠️ Erro ao processar</p>
                  )}
                </div>
              </div>
            ))}
            <div ref={messagesEndRef} />
          </>
        )}
        
        {sendMessageMutation.isPending && (
          <div className="flex justify-start">
            <div className="bg-white text-gray-900 border border-gray-200 shadow-sm rounded-lg px-4 py-2">
              <div className="flex items-center gap-2">
                <Loader2 className="h-4 w-4 animate-spin" />
                <span className="text-sm text-gray-600">Processando...</span>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Input */}
      <form onSubmit={handleSendMessage} className="p-4 bg-white border-t border-gray-200">
        <div className="flex items-center gap-2">
          <Input
            type="text"
            placeholder="Digite sua pergunta..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            disabled={sendMessageMutation.isPending}
            className="flex-1"
            data-testid="input-chat-message"
          />
          <Button
            type="submit"
            size="icon"
            disabled={!message.trim() || sendMessageMutation.isPending}
            className="shrink-0"
            data-testid="button-send-message"
          >
            {sendMessageMutation.isPending ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Send className="h-4 w-4" />
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}
