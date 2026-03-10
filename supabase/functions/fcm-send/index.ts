import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { JWT } from "https://esm.sh/google-auth-library@9"

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('MY_PROJECT_URL')!
    const supabaseKey = Deno.env.get('ADMIN_INTERNAL_KEY')!
    const fcmProject = Deno.env.get('FIREBASE_PROJECT_ID')!
    const fcmEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')!
    const fcmKey = Deno.env.get('FIREBASE_PRIVATE_KEY')!.replace(/\\n/g, '\n')

    const supabase = createClient(supabaseUrl, supabaseKey)

    const { record } = await req.json()
    
    const { data: user, error } = await supabase
      .from('users')
      .select('fcm_token')
      .eq('id', record.user_id)
      .single()

    if (error || !user?.fcm_token) {
      return new Response(JSON.stringify({ error: "No Token Found" }), { status: 404 })
    }

    const client = new JWT({
      email: fcmEmail,
      key: fcmKey,
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    })
    const jwtToken = await client.authorize()

    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${fcmProject}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${jwtToken.access_token}`,
        },
        body: JSON.stringify({
          message: {
            token: user.fcm_token,
            notification: {
              title: record.title || "StudyGrid Notification",
              body: record.body || "You have a new notification from StudyGrid!",
            },
          },
        }),
      }
    )

    const result = await fcmResponse.json()
    return new Response(JSON.stringify({ message: "Done", result }), { status: 200 })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})