import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chess_board.dart';

// ─── Modèles — Couche Domain (POO : encapsulation) ───────────────────────────

class TutorialStep {
  final String title;
  final String content;
  final String emoji;
  final String? fen;
  final List<String> highlightSquares;

  const TutorialStep({
    required this.title,
    required this.content,
    required this.emoji,
    this.fen,
    this.highlightSquares = const [],
  });
}

class TutorialLesson {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<TutorialStep> steps;

  const TutorialLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.steps,
  });
}

// ─── Données des 3 leçons ─────────────────────────────────────────────────────

final List<TutorialLesson> lessons = [
  const TutorialLesson(
    id: 'lesson_1',
    title: 'Les pièces',
    subtitle: 'Les 6 pièces et leurs mouvements',
    emoji: '♟',
    color: AppColors.primary,
    steps: [
      TutorialStep(
        emoji: '♔',
        title: 'Le Roi',
        content: 'Le Roi est la pièce la plus importante.'
            '\n\nIl se déplace d\'une seule case dans toutes les directions.'
            '\n\nSi votre Roi est capturé, vous perdez la partie !',
        fen: '8/8/8/8/4K3/8/8/8 w - - 0 1',
        highlightSquares: ['d3', 'd4', 'd5', 'e3', 'e5', 'f3', 'f4', 'f5'],
      ),
      TutorialStep(
        emoji: '♕',
        title: 'La Dame',
        content: 'La Dame est la pièce la plus puissante.'
            '\n\nElle se déplace dans toutes les directions sans limite.'
            '\n\nProtégez-la, sa perte est souvent fatale !',
        fen: '8/8/8/8/4Q3/8/8/8 w - - 0 1',
        highlightSquares: [
          'e1',
          'e2',
          'e3',
          'e5',
          'e6',
          'e7',
          'e8',
          'a4',
          'b4',
          'c4',
          'd4',
          'f4',
          'g4',
          'h4',
          'a8',
          'b7',
          'c6',
          'd5',
          'f3',
          'g2',
          'h1',
          'h7',
          'g6',
          'f5',
          'd3',
          'c2',
          'b1',
        ],
      ),
      TutorialStep(
        emoji: '♖',
        title: 'La Tour',
        content: 'La Tour se déplace horizontalement ou verticalement.'
            '\n\nElle ne peut pas sauter par-dessus les autres pièces.'
            '\n\nTrès puissante en fin de partie !',
        fen: '8/8/8/8/4R3/8/8/8 w - - 0 1',
        highlightSquares: [
          'e1',
          'e2',
          'e3',
          'e5',
          'e6',
          'e7',
          'e8',
          'a4',
          'b4',
          'c4',
          'd4',
          'f4',
          'g4',
          'h4',
        ],
      ),
      TutorialStep(
        emoji: '♗',
        title: 'Le Fou',
        content: 'Le Fou se déplace en diagonale uniquement.'
            '\n\nChaque joueur a deux Fous, un sur les cases claires et un sur les sombres.'
            '\n\nIl reste toujours sur la même couleur !',
        fen: '8/8/8/8/4B3/8/8/8 w - - 0 1',
        highlightSquares: [
          'a8',
          'b7',
          'c6',
          'd5',
          'f3',
          'g2',
          'h1',
          'h7',
          'g6',
          'f5',
          'd3',
          'c2',
          'b1',
        ],
      ),
      TutorialStep(
        emoji: '♘',
        title: 'Le Cavalier',
        content:
            'Le Cavalier est la seule pièce qui saute par-dessus les autres !'
            '\n\nIl se déplace en L : 2 cases puis 1 case perpendiculaire.'
            '\n\nCette particularité le rend très imprévisible.',
        fen: '8/8/8/8/4N3/8/8/8 w - - 0 1',
        highlightSquares: ['d2', 'f2', 'c3', 'g3', 'c5', 'g5', 'd6', 'f6'],
      ),
      TutorialStep(
        emoji: '♙',
        title: 'Le Pion',
        content: 'Le Pion avance d\'une case vers l\'avant.'
            '\n\nAu premier coup il peut avancer de 2 cases, et il capture en diagonale.'
            '\n\nS\'il atteint la dernière rangée, il devient une Dame !',
        fen: '8/8/8/8/8/8/4P3/8 w - - 0 1',
        highlightSquares: ['e3', 'e4', 'd3', 'f3'],
      ),
    ],
  ),
  const TutorialLesson(
    id: 'lesson_2',
    title: 'Règles spéciales',
    subtitle: 'Roque, en passant et promotion',
    emoji: '♚',
    color: AppColors.success,
    steps: [
      TutorialStep(
        emoji: '🏰',
        title: 'Le petit roque',
        content: 'Le Roque est le seul coup où deux pièces bougent ensemble.'
            '\n\nPetit roque côté Roi : le Roi va en g1 et la Tour vient en f1.'
            '\n\nConditions : ni le Roi ni la Tour n\'ont bougé, aucune pièce entre eux.',
        fen: 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1',
        highlightSquares: ['e1', 'h1', 'f1', 'g1'],
      ),
      TutorialStep(
        emoji: '🏯',
        title: 'Le grand roque',
        content:
            'Grand roque côté Dame : le Roi va en c1 et la Tour vient en d1.'
            '\n\nLe Roi ne doit pas traverser une case attaquée.'
            '\n\nLe Roi ne doit pas être en échec au moment de roquer.',
        fen: 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1',
        highlightSquares: ['e1', 'a1', 'd1', 'c1'],
      ),
      TutorialStep(
        emoji: '⚡',
        title: 'La prise en passant',
        content:
            'Si un pion adverse avance de 2 cases et se retrouve à côté de votre pion, vous pouvez le capturer en passant.'
            '\n\nCe coup n\'est possible qu\'immédiatement après le double avancement adverse.',
        fen: '8/8/8/3pP3/8/8/8/8 w - d6 0 1',
        highlightSquares: ['e5', 'd5', 'd6'],
      ),
      TutorialStep(
        emoji: '👑',
        title: 'La promotion',
        content:
            'Quand un pion atteint la dernière rangée, il se transforme en une autre pièce.'
            '\n\nOn choisit presque toujours la Dame car c\'est la plus puissante !'
            '\n\nUn pion qui promeut peut changer le résultat d\'une partie perdue.',
        fen: '8/4P3/8/8/8/8/8/8 w - - 0 1',
        highlightSquares: ['e7', 'e8'],
      ),
      TutorialStep(
        emoji: '⚠️',
        title: 'L\'échec',
        content:
            'Le Roi est en ÉCHEC quand il est attaqué par une pièce adverse.'
            '\n\nVous devez OBLIGATOIREMENT sortir de l\'échec en déplaçant le Roi, capturant la pièce attaquante ou bloquant l\'attaque.',
        fen: '4q3/8/8/8/8/8/8/4K3 w - - 0 1',
        highlightSquares: ['e1', 'e8', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7'],
      ),
      TutorialStep(
        emoji: '🏁',
        title: 'Échec et mat',
        content:
            'L\'ÉCHEC ET MAT se produit quand le Roi est en échec et qu\'aucune échappatoire n\'est possible.'
            '\n\nC\'est la fin de la partie ! Exemple classique : le mat du couloir où la Tour cloue le Roi sur la dernière rangée.',
        fen: 'R6k/8/8/8/8/8/8/7K b - - 0 1',
        highlightSquares: ['h8', 'a8', 'g8', 'g7', 'h7'],
      ),
    ],
  ),
  const TutorialLesson(
    id: 'lesson_3',
    title: 'Stratégie',
    subtitle: 'Les 5 principes fondamentaux',
    emoji: '♛',
    color: AppColors.accent,
    steps: [
      TutorialStep(
        emoji: '🎯',
        title: 'Contrôlez le centre',
        content:
            'Les 4 cases centrales d4, d5, e4, e5 sont les plus importantes du plateau.'
            '\n\nUne pièce au centre contrôle plus de cases et est plus mobile.'
            '\n\nCommencez toujours par e4 ou d4 !',
        fen: 'rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
        highlightSquares: ['d4', 'd5', 'e4', 'e5'],
      ),
      TutorialStep(
        emoji: '🚀',
        title: 'Développez vos pièces',
        content: 'Sortez rapidement vos Cavaliers et Fous dès le début.'
            '\n\nRègle simple : ne bougez pas deux fois la même pièce en ouverture.'
            '\n\nChaque coup doit développer une nouvelle pièce !',
        fen:
            'r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 1',
        highlightSquares: ['c4', 'f3', 'c6'],
      ),
      TutorialStep(
        emoji: '🛡️',
        title: 'Roquez tôt',
        content:
            'Roquez avant le milieu de partie pour mettre votre Roi en sécurité.'
            '\n\nUn Roi au centre du plateau est très vulnérable aux attaques !'
            '\n\nLe roque met aussi votre Tour en jeu, double bénéfice.',
        fen:
            'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 0 1',
        highlightSquares: ['e1', 'g1', 'h1', 'f1'],
      ),
      TutorialStep(
        emoji: '💎',
        title: 'Valeur des pièces',
        content: 'Mémorisez ces valeurs pour décider vos échanges.'
            '\n\nPion 1 pt, Cavalier et Fou 3 pts, Tour 5 pts, Dame 9 pts.'
            '\n\nN\'échangez jamais une Tour contre un simple Pion !',
        fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        highlightSquares: [],
      ),
      TutorialStep(
        emoji: '🔗',
        title: 'Connectez vos Tours',
        content:
            'Quand toutes vos pièces sont développées et votre Roi est en sécurité, connectez vos deux Tours.'
            '\n\nDeux Tours sur la même rangée se protègent et contrôlent une colonne entière.',
        fen: '3rr1k1/8/8/8/8/8/8/3RR1K1 w - - 0 1',
        highlightSquares: ['d1', 'e1', 'd8', 'e8'],
      ),
    ],
  ),
];

// ─── Écran principal des tutoriels ────────────────────────────────────────────

class TutorialScreen extends ConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(userProvider).valueOrNull;
    final completed = player?.completedTutorials ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tutoriels',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: AppColors.accent, height: 3),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildProgressHeader(completed.length),
            // const SizedBox(height: 28),
            const Text(
              'Choisissez une leçon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...lessons.asMap().entries.map((entry) {
              final lesson = entry.value;
              final isCompleted = completed.contains(lesson.id);
              return _LessonCard(
                lesson: lesson,
                isCompleted: isCompleted,
                lessonIndex: entry.key + 1,
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => LessonScreen(lesson: lesson),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Carte d'une leçon — SANS numéro, SANS badge Complétée ───────────────────

class _LessonCard extends StatelessWidget {
  final TutorialLesson lesson;
  final bool isCompleted;
  final int lessonIndex;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.lessonIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withOpacity(0.4)
                : lesson.color.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: lesson.color.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Bandeau haut — SANS numéro, SANS badge Complétée
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: lesson.color.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  // Emoji de la leçon au lieu du numéro
                  // Text(lesson.emoji, style: const TextStyle(fontSize: 30)),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: lesson.color,
                            )),
                        Text(lesson.subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                 
                ],
              ),
            ),
            // Bas de carte — bouton "Voir" ou "Commencer"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      color: lesson.color.withOpacity(0.5), size: 16),
                  const SizedBox(width: 6),
                  Text('${lesson.steps.length} étapes',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(width: 12),
                  Icon(Icons.extension_rounded,
                      color: lesson.color.withOpacity(0.5), size: 16),
                  const SizedBox(width: 6),
                  Text('Échiquier interactif',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: lesson.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      // "Voir" si complétée, "Commencer" sinon
                      isCompleted ? 'Voir' : 'Commencer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Écran d'une leçon ────────────────────────────────────────────────────────

class LessonScreen extends ConsumerStatefulWidget {
  final TutorialLesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _slideController;
  late AnimationController _boardController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _boardFade;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _boardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _boardFade = CurvedAnimation(
      parent: _boardController,
      curve: Curves.easeOut,
    );

    _slideController.forward();
    _boardController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(widget.lesson.steps[_currentStep].content);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _slideController.dispose();
    _boardController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
    await _tts.speak(
      text.replaceAll('\n\n', ', ').replaceAll('\n', ' '),
    );
  }

  Future<void> _goToStep(int newStep, bool goLeft) async {
    await _tts.stop();
    await _slideController.reverse();
    _boardController.reset();

    setState(() => _currentStep = newStep);

    _slideAnim = Tween<Offset>(
      begin: Offset(goLeft ? 1 : -1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    _boardController.forward();
    _speak(widget.lesson.steps[_currentStep].content);
  }

  void _nextStep() {
    if (_currentStep < widget.lesson.steps.length - 1) {
      _goToStep(_currentStep + 1, true);
    } else {
      _completeLesson();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1, false);
  }

  Future<void> _completeLesson() async {
    await _tts.stop();
    // Sauvegarde dans Firebase
    await ref.read(userProvider.notifier).completeTutorial(widget.lesson.id);
    // Retourne directement à la liste des tutoriels sans modal
    if (mounted) Navigator.pop(context);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('Leçon complétée !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Vous maîtrisez "${widget.lesson.title}" !',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Retour aux leçons',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.lesson.steps[_currentStep];
    final total = widget.lesson.steps.length;
    final isLast = _currentStep == total - 1;
    final color = widget.lesson.color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            _tts.stop();
            Navigator.pop(context);
          },
        ),
        title: Text(widget.lesson.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.accent),
            tooltip: 'Relire',
            onPressed: () => _speak(step.content),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: AppColors.accent, height: 3),
        ),
      ),
      body: Column(
        children: [
          // Barre de progression
          _buildProgressBar(total, color),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu texte animé
                  SlideTransition(
                    position: _slideAnim,
                    child: _buildStepContent(step, color),
                  ),
                  const SizedBox(height: 16),
                  // Échiquier interactif
                  if (step.fen != null)
                    Expanded(
                      child: FadeTransition(
                        opacity: _boardFade,
                        child: _buildBoard(step),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Boutons navigation
          _buildNavButtons(isLast, color),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int total, Color color) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Étape ${_currentStep + 1} / $total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )),
              Text(
                '${((_currentStep + 1) / total * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
                total,
                (i) => Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 5,
                        decoration: BoxDecoration(
                          color: i <= _currentStep
                              ? color
                              : color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(step.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
               step.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      )),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          step.content.replaceAll('\n\n', ' · ').replaceAll('\n', ' '),
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF444444),
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(TutorialStep step) {
    final chess = chess_lib.Chess.fromFEN(step.fen!, check_validity: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.touch_app_rounded,
                size: 13, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(width: 5),
            Text(
              'Cases vertes = mouvements possibles',
              style: TextStyle(
                  fontSize: 11, color: AppColors.primary.withOpacity(0.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ChessBoardWidget(
            chess: chess,
            legalMoves: step.highlightSquares,
            onSquareTap: (_) {},
          ),
        ),
      ],
    );
  }

  Widget _buildNavButtons(bool isLast, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _nextStep,
              icon: Icon(
                // Icône fermer sur la dernière étape
                isLast ? Icons.close_rounded : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(
                // "Fermer" sur la dernière étape au lieu de "Terminer"
                isLast ? 'Fermer' : 'Étape suivante',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppColors.success : color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
