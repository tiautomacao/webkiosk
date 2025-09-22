package com.example.webdeliverylegal

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper

class MyBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // Verifica se a ação recebida é a de boot completo
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            
            // Cria um Handler para adicionar um atraso
            Handler(Looper.getMainLooper()).postDelayed({
                // Cria um Intent para iniciar a MainActivity do seu aplicativo
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                
                // Inicia o aplicativo
                context.startActivity(launchIntent)
            }, 1500) // Atraso de 5 segundos (5000 milissegundos)
        }
    }
}