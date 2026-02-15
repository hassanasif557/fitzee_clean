const functions = require("firebase-functions");
const { defineSecret } = require("firebase-functions/params");
const OpenAI = require("openai");

// Define secret
const openaiKey = defineSecret("OPENAI_API_KEY");

// Map app food keys to clear names for the AI (Pakistan-friendly)
const LIKED_FOOD_LABELS = {
  rice: "rice",
  wheat_bread_roti_naan: "roti/naan",
  daal: "daal",
  biryani: "biryani",
  karahi: "karahi",
  curry: "curry",
  chicken_dishes: "chicken dishes",
  beef_mutton: "beef/mutton",
  vegetables: "vegetables",
  salads: "salads",
  fast_food: "fast food",
  eggs: "eggs",
  yogurt_dahi: "dahi (yogurt)",
  paratha: "paratha",
  halwa_sweet: "halwa and sweets",
  kheer: "kheer",
  qorma: "qorma",
  kebabs: "kebabs",
  pakora_samosa: "pakora/samosa",
  desi_breakfast: "desi breakfast (e.g. anda, paratha)",
};

exports.generateMealPlan = functions
  .https.onCall(
    {
      secrets: [openaiKey],
    },
    async (data, context) => {
      // ❌ Removed authentication check

      let {
        calories,
        dietPreference,
        medicalConditions,
        allergies,
        preferredCuisine = "general",
        likedFoods = [],
        age,
        weight,
        primaryGoal,
      } = data || {};

      // App is Pakistan-first: default to Pakistani if cuisine missing or generic
      if (!preferredCuisine || preferredCuisine === "general") {
        preferredCuisine = "pakistani";
      }

      // Log so you can verify in Firebase Functions logs that preferences are received
      console.log("generateMealPlan input:", {
        preferredCuisine,
        likedFoodsCount: Array.isArray(likedFoods) ? likedFoods.length : 0,
        likedFoods: Array.isArray(likedFoods) ? likedFoods.slice(0, 5) : [],
      });

      const openai = new OpenAI({
        apiKey: await openaiKey.value(),
      });

      const isPakistaniOrDesi =
        String(preferredCuisine).toLowerCase() === "pakistani" ||
        String(preferredCuisine).toLowerCase() === "desi";

      const cuisineInstruction = isPakistaniOrDesi
        ? `STRICT RULE — YOU MUST suggest ONLY Pakistani/Desi meals. Do NOT suggest: oatmeal, quinoa, salmon, grilled chicken salad, vinaigrette, avocado, chia seeds, Western-style "healthy" meals. INSTEAD use only South Asian/Pakistani foods, e.g.:
- Breakfast: paratha, anda (eggs), halwa puri, dahi, nashta (desi breakfast), roti with sabzi, etc.
- Lunch/Dinner: roti/naan, rice, daal, biryani, karahi (chicken/mutton), qorma, sabzi, curry, kebabs, daal chawal, etc.
- Snacks: chai, samosa, pakora, fruit chaat, etc.
Every meal must be clearly Pakistani/Desi; no generic Western meals.`
        : `Prefer ${preferredCuisine} cuisine.`;

      const likedFoodsList = Array.isArray(likedFoods)
        ? likedFoods
            .filter((f) => f && String(f).trim())
            .map((key) => LIKED_FOOD_LABELS[key] || key)
        : [];
      const likedFoodsNote =
        likedFoodsList.length > 0
          ? `The user LIKES these foods — you MUST include at least 2–3 in today's plan: ${likedFoodsList.join(", ")}. Use these in your suggestions; do not ignore them. Vary which ones each day.`
          : "Vary the meal suggestions so they are not repetitive.";

      const prompt = `Create a daily healthy meal plan.

CRITICAL — CUISINE RULE (follow strictly):
${cuisineInstruction}

${likedFoodsNote}

Constraints:
- Calories target: ${calories}
- Diet: ${dietPreference}
- Medical conditions: ${medicalConditions}
- Allergies: ${allergies}
${age != null ? `- Age: ${age}` : ""}
${weight != null ? `- Weight: ${weight} kg` : ""}
${primaryGoal ? `- Goal: ${primaryGoal}` : ""}

HEALTH & PRECAUTIONS (mandatory):
- Prefer baked, steamed, or lightly cooked foods over deep-fried or very oily options when possible.
- When you DO suggest oily or calorie-dense items (e.g. paratha, puri, pakora, biryani with extra ghee, halwa, fried snacks), you MUST add clear "precautions" so the user eats them safely. Examples: "Limit to one paratha", "Use minimal oil or heart-healthy oil (olive/canola) for cooking", "Have only 1–2 pieces of pakora", "Keep halwa portion small (2–3 tbsp)", "Avoid extra ghee on top".
- Every meal that is even slightly oily or high-calorie must have at least 1–2 precautions. Use the precautions array to list short, actionable tips.

For EACH meal you must:
1. Explain WHY you suggest it: link to the user's goal (e.g. fat loss, medical), conditions (e.g. diabetes-friendly, heart-friendly), and calories/diet.
2. Give 2–3 replacement options (alternatives) the user can choose instead.
3. Give 1–3 precautions (short tips) for healthier eating—especially for paratha, puri, fried items, biryani, halwa, or any oily food. Examples: "Don't eat more than one paratha", "Use less oil and prefer olive or mustard oil", "Limit to one small serving".

Return ONLY valid JSON (no markdown, no code block). Use this exact structure for each of breakfast, lunch, dinner, snacks:
{
  "breakfast": { "meal": "full meal description", "reason": "why we suggest this", "alternatives": ["alt 1", "alt 2", "alt 3"], "precautions": ["precaution 1", "precaution 2"] },
  "lunch": { "meal": "...", "reason": "...", "alternatives": ["...", "...", "..."], "precautions": ["...", "..."] },
  "dinner": { "meal": "...", "reason": "...", "alternatives": ["...", "...", "..."], "precautions": ["...", "..."] },
  "snacks": { "meal": "...", "reason": "...", "alternatives": ["...", "...", "..."], "precautions": ["...", "..."] }
}
Every slot must have meal, reason, alternatives (2–3 strings), and precautions (1–3 short strings).`;

      const systemMessage = isPakistaniOrDesi
        ? "You are a meal planner for a Pakistan/South Asia focused app. Suggest only Pakistani/Desi foods (roti, paratha, daal, biryani, karahi, etc.). Never suggest oatmeal, quinoa, salmon, or Western-style salads as main meals. When suggesting oily or fried items (paratha, puri, pakora, halwa, extra ghee), you MUST always add precautions: e.g. limit portions (one paratha), use less oil or healthy oil (olive/canola/mustard), avoid extra ghee."
        : "You are a meal planner. Suggest meals that match the user's preferred cuisine and constraints. For oily or calorie-dense items, always add precautions (portion limits, use less/healthy oil).";

      try {
        const completion = await openai.chat.completions.create({
          model: "gpt-4.1-mini",
          messages: [
            { role: "system", content: systemMessage },
            { role: "user", content: prompt },
          ],
          temperature: 0.7,
        });

        let raw = completion.choices[0].message.content || "";
        const codeBlock = raw.match(/```(?:json)?\s*([\s\S]*?)```/);
        if (codeBlock) raw = codeBlock[1].trim();
        const parsed = JSON.parse(raw);

        const toSlot = (obj) => {
          if (!obj || typeof obj !== "object") return { meal: "", reason: "", alternatives: [], precautions: [] };
          return {
            meal: obj.meal != null ? String(obj.meal) : "",
            reason: obj.reason != null ? String(obj.reason) : "",
            alternatives: Array.isArray(obj.alternatives)
              ? obj.alternatives.map((a) => String(a)).filter(Boolean)
              : [],
            precautions: Array.isArray(obj.precautions)
              ? obj.precautions.map((p) => String(p)).filter(Boolean)
              : [],
          };
        };

        return {
          breakfast: toSlot(parsed.breakfast),
          lunch: toSlot(parsed.lunch),
          dinner: toSlot(parsed.dinner),
          snacks: toSlot(parsed.snacks),
        };
      } catch (err) {
        throw new functions.https.HttpsError("internal", err.message);
      }
    }
  );

