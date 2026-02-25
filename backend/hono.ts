import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

app.use("*", cors());

const TOOLKIT_URL = process.env["EXPO_PUBLIC_TOOLKIT_URL"] ?? "https://toolkit.rork.com";

const aiResponseJsonSchema = {
  type: "object",
  properties: {
    honne: { type: "string" },
    psychologicalState: { type: "string" },
    suggestedResponse: { type: "string" },
    emotionLevel: { type: "number", minimum: 1, maximum: 5 },
  },
  required: ["honne", "psychologicalState", "suggestedResponse", "emotionLevel"],
};

app.get("/", (c) => {
  return c.json({ status: "ok", message: "API is running" });
});

app.post("/translate", async (c) => {
  try {
    const body = await c.req.json();
    const { text, relationship } = body;

    if (!text || !relationship) {
      return c.json({ error: "text and relationship are required" }, 400);
    }

    const prompt = `あなたは人間関係の専門家であり、心理カウンセラーです。
ユーザーが送ってきたメッセージや会話文を分析し、JSON形式で回答してください。

関係性: ${relationship}

以下のメッセージを分析してください：

${text}`;

    const response = await fetch(new URL("/llm/object", TOOLKIT_URL).toString(), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        messages: [
          { role: "user", content: prompt },
        ],
        schema: aiResponseJsonSchema,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("[translate] Toolkit error:", response.status, errorText);
      return c.json({ error: "AI analysis failed" }, 500);
    }

    const data = await response.json();

    return c.json({ success: true, data: data.object });
  } catch (error: any) {
    console.error("[translate] Error:", error);
    return c.json({ error: error.message || "AI analysis failed" }, 500);
  }
});

export default app;

