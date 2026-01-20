/// Frases de cobrança para motivar o cumprimento da tarefa
/// Todas armazenadas localmente para funcionamento offline
const List<String> cobrancePhrases = [
  // Frases sobre compromisso
  "Você fez um compromisso. Onde está sua disciplina? Cumpra agora.",
  "Você jurou dedicar 15 minutos. Não seja um tratante. Cumpra seu dever.",
  "Um homem que não cumpre suas promessas é um escravo de seus impulsos.",
  "Você prometeu a si mesmo. Agora honre essa promessa.",
  
  // Frases sobre estoicismo
  "O estoicismo não é para fracos. Levante-se e execute sua tarefa.",
  "Marcus Aurelius não teria deixado para depois. Cumpra seu dever agora.",
  "Epicteto dizia: 'Você é responsável por suas ações.' Aja.",
  "Sêneca não acreditava em procrastinação. Faça agora.",
  
  // Frases sobre virtude
  "A virtude não espera. Sua tarefa está pendente. Aja agora.",
  "Você é o arquiteto de seu destino. Construa-o com ação, não com desculpas.",
  "A excelência é um hábito. Comece agora.",
  "Virtude é o único bem verdadeiro. Cumpra sua tarefa.",
  
  // Frases sobre controle
  "Você é escravo de seus impulsos? Não. Você é um homem disciplinado. Cumpra.",
  "Você tem poder sobre sua mente. Use-o agora.",
  "O que está sob seu controle? Sua ação. Aja.",
  "Não deixe para depois o que depende de você.",
  
  // Frases sobre tempo
  "Cada minuto que passa é uma falha. Levante-se e termine sua tarefa.",
  "O tempo é seu bem mais precioso. Não o desperdice.",
  "Você não sabe se terá amanhã. Cumpra hoje.",
  "A vida é breve. Não a desperdice com adiamento.",
  
  // Frases sobre coragem
  "Coragem não é ausência de medo. É agir apesar dele. Cumpra.",
  "Você é mais forte do que pensa. Prove isso agora.",
  "Levante-se. Você tem a força necessária.",
  "A fraqueza é uma escolha. Escolha a força.",
  
  // Frases sobre responsabilidade
  "Você é responsável por suas ações. Assuma essa responsabilidade.",
  "Ninguém vai fazer por você. Você deve fazer.",
  "Sua vida é sua responsabilidade. Aja.",
  "Não culpe as circunstâncias. Você tem o poder.",
  
  // Frases sobre transformação
  "Cada ação é uma oportunidade de transformação. Comece agora.",
  "Você quer mudar? Comece com essa tarefa.",
  "A mudança começa com uma ação. Essa ação é agora.",
  "Você é capaz de mais do que imagina. Prove.",
  
  // Frases sobre perseverança
  "Perseverança é a chave. Não desista.",
  "Você já começou. Agora termine.",
  "A vitória vai para quem persevera. Seja esse homem.",
  "Não pare agora. Você está perto.",
  
  // Frases sobre disciplina
  "Disciplina é a ponte entre objetivos e realização. Cumpra.",
  "Disciplina é liberdade. Escolha a liberdade.",
  "Sem disciplina, não há progresso. Aja.",
  "Você quer ser livre? Comece sendo disciplinado.",
  
  // Frases sobre morte
  "Você é mortal. Não desperdice seu tempo.",
  "Cada dia é um presente. Não o desperdice.",
  "A morte vem para todos. Viva com propósito.",
  "Você pode morrer amanhã. Viva hoje com retidão.",
  
  // Frases motivacionais
  "Você é mais forte do que seus medos.",
  "Você é capaz. Você é digno. Você é disciplinado.",
  "Levante-se. O mundo precisa de você.",
  "Você é um estoico. Aja como tal.",
  
  // Frases sobre consequências
  "Cada momento de adiamento é uma falha de caráter.",
  "Você quer respeitar a si mesmo? Cumpra agora.",
  "Seu futuro eu agradecerá se você agir agora.",
  "Não deixe arrependimentos para depois.",
  
  // Frases sobre excelência
  "Excelência não é um destino. É um hábito. Comece.",
  "Você quer ser excelente? Comece com essa tarefa.",
  "Mediocidade é para os fracos. Você é forte.",
  "Você merece o melhor. Comece agora.",
];

/// Obtém uma frase aleatória de cobrança
String getRandomCobrancePhrase() {
  final random = DateTime.now().millisecond % cobrancePhrases.length;
  return cobrancePhrases[random];
}

/// Obtém uma frase específica pelo índice
String getCobrancePhraseByIndex(int index) {
  if (index < 0 || index >= cobrancePhrases.length) {
    return cobrancePhrases[0];
  }
  return cobrancePhrases[index];
}

/// Obtém uma frase baseada na hora do dia
String getCobrancePhraseByTime() {
  final hour = DateTime.now().hour;
  
  if (hour >= 5 && hour < 12) {
    // Manhã: frases sobre começar o dia
    return "Você acordou. Agora cumpra sua tarefa.";
  } else if (hour >= 12 && hour < 18) {
    // Tarde: frases sobre não deixar para depois
    return "O dia está passando. Não deixe para depois.";
  } else if (hour >= 18 && hour < 22) {
    // Noite: frases sobre terminar o dia com honra
    return "O dia está terminando. Termine com honra.";
  } else {
    // Madrugada: frases sobre desistência
    return "Você ainda está acordado? Cumpra sua tarefa e durma em paz.";
  }
}
