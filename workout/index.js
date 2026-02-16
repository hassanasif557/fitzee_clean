const functions = require("firebase-functions");
const { defineSecret } = require("firebase-functions/params");
const OpenAI = require("openai");

const openaiKey = defineSecret("OPENAI_API_KEY");

/**
 * AI-generated workout plan based on user profile (goal, medical conditions, physical).
 * Receives available exercises (id, name, goals, difficulty, medicalRestrictions, muscleGroup)
 * and returns for each day: day, workoutType, exerciseIds.
 * App resolves exerciseIds to full Exercise objects from ExerciseDatabaseService.
 */
exports.generateWorkoutPlan = functions.https.onCall(
  { secrets: [openaiKey] },
    async (data, context) => {
      const {
        goal = "fat_loss",
        difficulty = "beginner",
        daysPerWeek = 3,
        medicalConditions = [],
        availableExercises = [],
      } = data || {};

      if (!Array.isArray(availableExercises) || availableExercises.length === 0) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "availableExercises must be a non-empty array"
        );
      }

      const openai = new OpenAI({
        apiKey: await openaiKey.value(),
      });

      const exerciseList = availableExercises
        .map(
          (e) =>
            `- id: "${e.id}", name: ${e.name}, goals: [${(e.goals || []).join(", ")}], difficulty: ${e.difficulty}, medicalRestrictions: [${(e.medicalRestrictions || []).join(", ")}], muscleGroup: ${e.muscleGroup}`
        )
        .join("\n");

      const medicalNote =
        medicalConditions.length > 0
          ? `CRITICAL: The user has these medical considerations — you MUST NOT suggest any exercise whose medicalRestrictions list includes any of: ${medicalConditions.join(", ")}. Only use exercises that are safe for the user.`
          : "No specific medical restrictions.";

      const prompt = `You are a safe, professional workout planner. Create a ${daysPerWeek}-day weekly workout plan.

User context:
- Goal: ${goal}
- Difficulty level: ${difficulty}
- Medical/health considerations: ${medicalNote}

Available exercises (you MUST only use these exact ids — no other exercises exist):
${exerciseList}

Rules:
1. For each day, output exactly one workout with: day (e.g. "Monday", "Tuesday"), workoutType (one of: full_body, upper_body, lower_body, cardio, rehab), and exerciseIds (array of exercise id strings from the list above).
2. Respect medical restrictions: do NOT include any exercise whose medicalRestrictions contain any of the user's conditions.
3. Match goal: use only exercises whose "goals" array includes "${goal}" (or "rehab" if goal is rehab, "fat_loss" if goal is fat_loss or medical).
4. Match difficulty: prefer exercises with difficulty "${difficulty}"; you may include one level easier if needed for safety.
5. Each day: include 1 warm-up (e.g. marching_in_place, arm_circles, neck_rolls), 4–6 main exercises, and 1 cool-down/stretch (e.g. standing_quad_stretch, shoulder_stretch, hamstring_stretch) when available.
6. Vary muscle groups across the week. For full_body days use a mix of legs, chest, arms, core; for upper_body use chest/arms/back; for lower_body use legs/core.
7. Return ONLY valid JSON, no markdown or code fence.

Return this exact structure:
{
  "goal": "${goal}",
  "difficulty": "${difficulty}",
  "days": [
    { "day": "Monday", "workoutType": "full_body", "exerciseIds": ["marching_in_place", "squat_bodyweight", "wall_pushup", "plank", "standing_quad_stretch"] },
    ... one object per day, ${daysPerWeek} days total
  ]
}`;

      try {
        const completion = await openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content:
                "You are a safe workout planner. You only output valid JSON. You never suggest exercises that are contraindicated for the user's medical conditions. You only use exercise ids from the provided list.",
            },
            { role: "user", content: prompt },
          ],
          temperature: 0.3,
        });

        let raw = completion.choices[0].message.content || "";
        const codeBlock = raw.match(/```(?:json)?\s*([\s\S]*?)```/);
        if (codeBlock) raw = codeBlock[1].trim();
        const parsed = JSON.parse(raw);

        const days = Array.isArray(parsed.days)
          ? parsed.days.map((d) => ({
              day: d.day || "Day " + (parsed.days.indexOf(d) + 1),
              workoutType: d.workoutType || "full_body",
              exerciseIds: Array.isArray(d.exerciseIds)
                ? d.exerciseIds.filter((id) => typeof id === "string")
                : [],
            }))
          : [];

        return {
          goal: parsed.goal || goal,
          difficulty: parsed.difficulty || difficulty,
          days,
        };
      } catch (err) {
        console.error("generateWorkoutPlan error:", err);
        throw new functions.https.HttpsError(
          "internal",
          err.message || "Workout plan generation failed"
        );
      }
    }
);
