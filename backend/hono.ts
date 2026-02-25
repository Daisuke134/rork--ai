import { Hono } from "hono";
import { cors } from "hono/cors";
import { generateObject } from "@rork-ai/toolkit-sdk";
import { z } from "zod";

const app = new Hono();

app.use("*", cors());

app.get("/", (c) => {
  return c.json({ status: "ok", message: "API is running" });
});

const AIResponseSchema = z.object({
  honne: z.string(),
  psychologicalState: z.string(),
  suggestedResponse: z.string(),
  emotionLevel: z.number().min(1).max(5),
});

app.post("/translate", async (c) => {
  try {
    const body = await c.req.json();
    const { text, relationship } = body;

    if (!text || !relationship) {
      return c.json({ error: "text and relationship are required" }, 400);
    }

    const systemPrompt = `あなたは人間関係の専門家であり、心理カウンセラーです。
ユーザーが送ってきたメッセージや会話文を分析し、以下の形式でJSON形式で回答してください。

関係性: ${relationship}

必ず以下のJSON形式で回答してください。他のテキストは一切含めないでください：
{
    "honne": "相手の本音（本当に言いたいこと、隠された感情）を詳しく説明",
    "psychologicalState": "相手の心理状態を詳しく分析（不安、怒り、寂しさ、期待など）",
    "suggestedResponse": "この状況で最適な返答の例を具体的に提案",
    "emotionLevel": 1〜5の数字（1=穏やか、5=非常に感情的）
}`;

    const userMessage = `以下のメッセージを分析してください：\n\n${text}`;

    const result = await generateObject({
      messages: [
        { role: "user" as const, content: `${systemPrompt}\n\n${userMessage}` },
      ],
      schema: AIResponseSchema,
    });

    return c.json({ success: true, data: result });
  } catch (error: any) {
    console.error("[translate] Error:", error);
    return c.json({ error: error.message || "AI analysis failed" }, 500);
  }
});

export default app;
