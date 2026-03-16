import { useMemo, useState } from 'react';
import {
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View
} from 'react-native';
import { formatExerciseTypeLabel, formatTypeLabel, tr } from '../localization';
import {
  ClassLessonsFile,
  ClassNumber,
  ExerciseKind,
  LessonType
} from '../lib/types';

type Props = {
  classNumber: ClassNumber;
  data: ClassLessonsFile | null;
  onBack: () => void;
};

type ProposalTarget = 'lesson' | 'exercise';

type UploadedImage = {
  name: string;
  uri: string;
};

type QuizQuestionDraft = {
  id: string;
  question: string;
  singleChoiceText: string;
  trueFalse: 'True' | 'False';
  shortText: string;
};

type ExerciseDraft = {
  id: string;
  label: string;
  type: ExerciseKind;
  formats: ('all' | LessonType)[];
  text: string;
  columnsText: string;
  rowsText: string;
  dataToFillText: string;
  questionsText: string;
  youtubeUrl: string;
  videoUrl: string;
  connectColumn1Text: string;
  connectColumn2Text: string;
  connectDisplay: 'horizontal' | 'vertical';
  image: UploadedImage | null;
  interactiveQuestions: QuizQuestionDraft[];
};

const lessonFormats: LessonType[] = ['quiz', 'story', 'competition'];
const exerciseKinds: ExerciseKind[] = [
  'diagram',
  'table',
  'text',
  'rebus',
  'video',
  'interactive_quiz',
  'homework',
  'connect'
];

function createQuizQuestionDraft(index = 1): QuizQuestionDraft {
  return {
    id: `q${index}`,
    question: '',
    singleChoiceText: '',
    trueFalse: 'True',
    shortText: ''
  };
}

function createExerciseDraft(type: ExerciseKind = 'text'): ExerciseDraft {
  return {
    id: '',
    label: '',
    type,
    formats: ['all'],
    text: '',
    columnsText: '',
    rowsText: '',
    dataToFillText: '',
    questionsText: '',
    youtubeUrl: '',
    videoUrl: '',
    connectColumn1Text: '',
    connectColumn2Text: '',
    connectDisplay: 'horizontal',
    image: null,
    interactiveQuestions: [createQuizQuestionDraft(1)]
  };
}

function parseLines(value: string) {
  return value
    .split('\n')
    .map((item) => item.trim())
    .filter(Boolean);
}

function inferImageExt(image: UploadedImage | null) {
  if (!image) {
    return undefined;
  }

  const ext = image.name.split('.').pop()?.toLowerCase();
  if (ext === 'jpg' || ext === 'jpeg' || ext === 'png') {
    return ext;
  }
  return undefined;
}

async function pickImageOnWeb() {
  if (Platform.OS !== 'web' || typeof document === 'undefined') {
    return null;
  }

  return new Promise<UploadedImage | null>((resolve) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/png,image/jpeg,image/jpg';
    input.onchange = () => {
      const file = input.files?.[0];
      if (!file) {
        resolve(null);
        return;
      }
      resolve({
        name: file.name,
        uri: URL.createObjectURL(file)
      });
    };
    input.click();
  });
}

function buildExercisePayload(draft: ExerciseDraft) {
  const base = {
    id: draft.id.trim(),
    label: draft.label.trim(),
    type: draft.type,
    formats:
      draft.formats.length === 0 || draft.formats.includes('all')
        ? ['all']
        : draft.formats
  };

  switch (draft.type) {
    case 'diagram':
    case 'rebus':
      return {
        ...base,
        imageExt: inferImageExt(draft.image),
        imageFileName: draft.image?.name ?? ''
      };
    case 'table':
      return {
        ...base,
        columns: parseLines(draft.columnsText),
        rows: parseLines(draft.rowsText),
        dataToFill: parseLines(draft.dataToFillText)
      };
    case 'text':
      return {
        ...base,
        text: draft.text.trim(),
        questions: parseLines(draft.questionsText)
      };
    case 'video':
      return {
        ...base,
        youtubeUrl: draft.youtubeUrl.trim(),
        questions: parseLines(draft.questionsText)
      };
    case 'interactive_quiz':
      return {
        ...base,
        questions: draft.interactiveQuestions.map((question) => ({
          id: question.id.trim(),
          question: question.question.trim(),
          answerTypes: {
            singleChoice: parseLines(question.singleChoiceText),
            trueFalse: question.trueFalse,
            shortText: question.shortText.trim()
          }
        }))
      };
    case 'homework':
      return {
        ...base,
        text: draft.text.trim(),
        imageExt: inferImageExt(draft.image),
        imageFileName: draft.image?.name ?? '',
        videoUrl: draft.videoUrl.trim()
      };
    case 'connect':
      return {
        ...base,
        text: draft.text.trim(),
        column1Items: parseLines(draft.connectColumn1Text),
        column2Items: parseLines(draft.connectColumn2Text),
        display: draft.connectDisplay
      };
    default:
      return base;
  }
}

function SelectionPills<T extends string>({
  options,
  selected,
  onSelect,
  getLabel
}: {
  options: T[];
  selected: T;
  onSelect: (value: T) => void;
  getLabel?: (value: T) => string;
}) {
  return (
    <View style={styles.pillsWrap}>
      {options.map((option) => {
        const active = selected === option;
        return (
          <Pressable
            key={option}
            onPress={() => onSelect(option)}
            style={[styles.pill, active && styles.pillActive]}
          >
            <Text style={[styles.pillText, active && styles.pillTextActive]}>
              {getLabel ? getLabel(option) : option}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

function MultiSelectPills<T extends string>({
  options,
  selected,
  onToggle,
  getLabel
}: {
  options: T[];
  selected: T[];
  onToggle: (value: T) => void;
  getLabel?: (value: T) => string;
}) {
  return (
    <View style={styles.pillsWrap}>
      {options.map((option) => {
        const active = selected.includes(option);
        return (
          <Pressable
            key={option}
            onPress={() => onToggle(option)}
            style={[styles.pill, active && styles.pillActive]}
          >
            <Text style={[styles.pillText, active && styles.pillTextActive]}>
              {getLabel ? getLabel(option) : option}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

function ExerciseDraftEditor({
  draft,
  onChange,
  title
}: {
  draft: ExerciseDraft;
  onChange: (next: ExerciseDraft) => void;
  title: string;
}) {
  const toggleFormat = (format: 'all' | LessonType) => {
    const nextFormats = draft.formats.includes(format)
      ? draft.formats.filter((item) => item !== format)
      : [...draft.formats.filter((item) => item !== 'all'), format];

    if (format === 'all') {
      onChange({ ...draft, formats: ['all'] });
      return;
    }

    onChange({
      ...draft,
      formats: nextFormats.length === 0 ? ['all'] : nextFormats
    });
  };

  const handlePickImage = async () => {
    const image = await pickImageOnWeb();
    if (image) {
      onChange({ ...draft, image });
    }
  };

  return (
    <View style={styles.formCard}>
      <Text style={styles.sectionTitle}>{title}</Text>

      <Text style={styles.fieldLabel}>{tr('exerciseId')}</Text>
      <TextInput
        value={draft.id}
        onChangeText={(value) => onChange({ ...draft, id: value })}
        style={styles.input}
      />

      <Text style={styles.fieldLabel}>{tr('exerciseLabel')}</Text>
      <TextInput
        value={draft.label}
        onChangeText={(value) => onChange({ ...draft, label: value })}
        style={styles.input}
      />

      <Text style={styles.fieldLabel}>{tr('exerciseType')}</Text>
      <SelectionPills
        options={exerciseKinds}
        selected={draft.type}
        onSelect={(value) => onChange({ ...draft, type: value })}
        getLabel={(value) => formatExerciseTypeLabel(value)}
      />

      <Text style={styles.fieldLabel}>{tr('type')}</Text>
      <MultiSelectPills
        options={['all', ...lessonFormats]}
        selected={draft.formats}
        onToggle={toggleFormat}
        getLabel={(value) => (value === 'all' ? tr('allExercises') : formatTypeLabel(value))}
      />

      {(draft.type === 'diagram' || draft.type === 'rebus' || draft.type === 'homework') ? (
        <>
          <Text style={styles.fieldLabel}>{tr('imageUpload')}</Text>
          <Pressable onPress={handlePickImage} style={styles.secondaryButton}>
            <Text style={styles.secondaryButtonText}>{tr('imageUpload')}</Text>
          </Pressable>
          <Text style={styles.fieldHint}>
            {Platform.OS === 'web' ? `${tr('uploadSelectedImage')}: ${draft.image?.name ?? '-'}` : tr('imageUploadHint')}
          </Text>
        </>
      ) : null}

      {(draft.type === 'text' || draft.type === 'homework' || draft.type === 'connect') ? (
        <>
          <Text style={styles.fieldLabel}>{tr('textContent')}</Text>
          <TextInput
            value={draft.text}
            onChangeText={(value) => onChange({ ...draft, text: value })}
            multiline
            style={[styles.input, styles.textArea]}
          />
        </>
      ) : null}

      {draft.type === 'table' ? (
        <>
          <Text style={styles.fieldLabel}>{tr('columns')}</Text>
          <TextInput
            value={draft.columnsText}
            onChangeText={(value) => onChange({ ...draft, columnsText: value })}
            multiline
            style={[styles.input, styles.textArea]}
            placeholder={tr('listItemsHint')}
          />

          <Text style={styles.fieldLabel}>{tr('rowNamesOptional')}</Text>
          <TextInput
            value={draft.rowsText}
            onChangeText={(value) => onChange({ ...draft, rowsText: value })}
            multiline
            style={[styles.input, styles.textArea]}
            placeholder={tr('listItemsHint')}
          />

          <Text style={styles.fieldLabel}>{tr('dataToFill')}</Text>
          <TextInput
            value={draft.dataToFillText}
            onChangeText={(value) => onChange({ ...draft, dataToFillText: value })}
            multiline
            style={[styles.input, styles.textArea]}
            placeholder={tr('listItemsHint')}
          />
        </>
      ) : null}

      {(draft.type === 'text' || draft.type === 'video') ? (
        <>
          <Text style={styles.fieldLabel}>{tr('questions')}</Text>
          <TextInput
            value={draft.questionsText}
            onChangeText={(value) => onChange({ ...draft, questionsText: value })}
            multiline
            style={[styles.input, styles.textArea]}
            placeholder={tr('listItemsHint')}
          />
        </>
      ) : null}

      {draft.type === 'video' ? (
        <>
          <Text style={styles.fieldLabel}>{tr('youtubeUrl')}</Text>
          <TextInput
            value={draft.youtubeUrl}
            onChangeText={(value) => onChange({ ...draft, youtubeUrl: value })}
            style={styles.input}
          />
        </>
      ) : null}

      {draft.type === 'homework' ? (
        <>
          <Text style={styles.fieldLabel}>{tr('youtubeUrl')}</Text>
          <TextInput
            value={draft.videoUrl}
            onChangeText={(value) => onChange({ ...draft, videoUrl: value })}
            style={styles.input}
          />
        </>
      ) : null}

      {draft.type === 'connect' ? (
        <>
          <Text style={styles.fieldLabel}>{tr('columnOne')}</Text>
          <TextInput
            value={draft.connectColumn1Text}
            onChangeText={(value) => onChange({ ...draft, connectColumn1Text: value })}
            multiline
            style={[styles.input, styles.textArea]}
            placeholder={tr('listItemsHint')}
          />

          <Text style={styles.fieldLabel}>{tr('columnTwo')}</Text>
          <TextInput
            value={draft.connectColumn2Text}
            onChangeText={(value) => onChange({ ...draft, connectColumn2Text: value })}
            multiline
            style={[styles.input, styles.textArea]}
            placeholder={tr('listItemsHint')}
          />

          <Text style={styles.fieldLabel}>{tr('displayMode')}</Text>
          <SelectionPills
            options={['horizontal', 'vertical']}
            selected={draft.connectDisplay}
            onSelect={(value) => onChange({ ...draft, connectDisplay: value })}
            getLabel={(value) =>
              value === 'horizontal' ? tr('connectDisplayHorizontal') : tr('connectDisplayVertical')
            }
          />
        </>
      ) : null}

      {draft.type === 'interactive_quiz' ? (
        <>
          {draft.interactiveQuestions.map((question, index) => (
            <View key={`question-${index}`} style={styles.quizQuestionCard}>
              <Text style={styles.fieldLabel}>{tr('questions')} {index + 1}</Text>
              <TextInput
                value={question.id}
                onChangeText={(value) =>
                  onChange({
                    ...draft,
                    interactiveQuestions: draft.interactiveQuestions.map((item, itemIndex) =>
                      itemIndex === index ? { ...item, id: value } : item
                    )
                  })
                }
                style={styles.input}
                placeholder="q1"
              />
              <TextInput
                value={question.question}
                onChangeText={(value) =>
                  onChange({
                    ...draft,
                    interactiveQuestions: draft.interactiveQuestions.map((item, itemIndex) =>
                      itemIndex === index ? { ...item, question: value } : item
                    )
                  })
                }
                style={[styles.input, styles.textArea]}
                multiline
                placeholder={tr('questions')}
              />
              <TextInput
                value={question.singleChoiceText}
                onChangeText={(value) =>
                  onChange({
                    ...draft,
                    interactiveQuestions: draft.interactiveQuestions.map((item, itemIndex) =>
                      itemIndex === index ? { ...item, singleChoiceText: value } : item
                    )
                  })
                }
                style={[styles.input, styles.textArea]}
                multiline
                placeholder={tr('singleChoiceOptions')}
              />
              <SelectionPills
                options={['True', 'False']}
                selected={question.trueFalse}
                onSelect={(value) =>
                  onChange({
                    ...draft,
                    interactiveQuestions: draft.interactiveQuestions.map((item, itemIndex) =>
                      itemIndex === index ? { ...item, trueFalse: value } : item
                    )
                  })
                }
              />
              <TextInput
                value={question.shortText}
                onChangeText={(value) =>
                  onChange({
                    ...draft,
                    interactiveQuestions: draft.interactiveQuestions.map((item, itemIndex) =>
                      itemIndex === index ? { ...item, shortText: value } : item
                    )
                  })
                }
                style={styles.input}
                placeholder={tr('correctAnswer')}
              />
            </View>
          ))}

          <Pressable
            onPress={() =>
              onChange({
                ...draft,
                interactiveQuestions: [
                  ...draft.interactiveQuestions,
                  createQuizQuestionDraft(draft.interactiveQuestions.length + 1)
                ]
              })
            }
            style={styles.secondaryButton}
          >
            <Text style={styles.secondaryButtonText}>{tr('questions')}</Text>
          </Pressable>
        </>
      ) : null}
    </View>
  );
}

export function ProposalPage({ classNumber, data, onBack }: Props) {
  const themeOptions = useMemo(
    () =>
      data?.modules.flatMap((module) =>
        module.themes.map((theme) => ({
          key: `${module.id}:${theme.id}`,
          moduleId: module.id,
          themeId: theme.id,
          themeName: module.title,
          lessons: theme.lessons
        }))
      ) ?? [],
    [data]
  );

  const [proposalType, setProposalType] = useState<ProposalTarget>('lesson');
  const [selectedThemeKey, setSelectedThemeKey] = useState(themeOptions[0]?.key ?? '');
  const [selectedLessonId, setSelectedLessonId] = useState(
    themeOptions[0]?.lessons[0]?.id ?? ''
  );
  const [lessonTitle, setLessonTitle] = useState('');
  const [lessonId, setLessonId] = useState('');
  const [lessonTopic, setLessonTopic] = useState('');
  const [lessonProposalFormats, setLessonProposalFormats] = useState<LessonType[]>(['quiz']);
  const [singleExerciseDraft, setSingleExerciseDraft] = useState<ExerciseDraft>(createExerciseDraft());
  const [lessonExerciseDrafts, setLessonExerciseDrafts] = useState<ExerciseDraft[]>([createExerciseDraft()]);
  const [proposalPreview, setProposalPreview] = useState('');

  const selectedThemeOption = useMemo(
    () => themeOptions.find((theme) => theme.key === selectedThemeKey) ?? null,
    [selectedThemeKey, themeOptions]
  );
  const selectedLesson = useMemo(
    () => selectedThemeOption?.lessons.find((lesson) => lesson.id === selectedLessonId) ?? null,
    [selectedLessonId, selectedThemeOption]
  );

  const toggleLessonFormat = (format: LessonType) => {
    setLessonProposalFormats((prev) =>
      prev.includes(format) ? prev.filter((item) => item !== format) : [...prev, format]
    );
  };

  const submitProposal = () => {
    if (!selectedThemeOption) {
      return;
    }

    const base = {
      classNumber,
      moduleId: selectedThemeOption.moduleId,
      themeId: selectedThemeOption.themeId,
      themeName: selectedThemeOption.themeName
    };

    const payload =
      proposalType === 'lesson'
        ? {
            ...base,
            proposalType: 'lesson',
            lesson: {
              id: lessonId.trim(),
              title: lessonTitle.trim(),
              topic: lessonTopic.trim(),
              formats: lessonProposalFormats,
              exercises: lessonExerciseDrafts.map(buildExercisePayload)
            }
          }
        : {
            ...base,
            proposalType: 'exercise',
            lessonId: selectedLessonId,
            exercise: buildExercisePayload(singleExerciseDraft)
          };

    setProposalPreview(JSON.stringify(payload, null, 2));
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.topBar}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backButtonText}>{tr('back')}</Text>
        </Pressable>
      </View>

      <Text style={styles.pageTitle}>{tr('createProposal')}</Text>
      <Text style={styles.pageMeta}>{tr('classLabel')}: {classNumber}</Text>
      {selectedThemeOption ? (
        <Text style={styles.pageMeta}>{tr('theme')}: {selectedThemeOption.themeName}</Text>
      ) : null}
      {proposalType === 'exercise' && selectedLesson ? (
        <Text style={styles.pageMeta}>{tr('lessonTitle')}: {selectedLesson.title}</Text>
      ) : null}

      <View style={styles.formCard}>
        <Text style={styles.fieldLabel}>{tr('proposalType')}</Text>
        <SelectionPills
          options={['lesson', 'exercise']}
          selected={proposalType}
          onSelect={setProposalType}
          getLabel={(value) => (value === 'lesson' ? tr('newLesson') : tr('newExercise'))}
        />

        <Text style={styles.fieldLabel}>{tr('selectTheme')}</Text>
        <SelectionPills
          options={themeOptions.map((theme) => theme.key)}
          selected={selectedThemeKey}
          onSelect={(value) => {
            setSelectedThemeKey(value);
            const nextTheme = themeOptions.find((theme) => theme.key === value);
            setSelectedLessonId(nextTheme?.lessons[0]?.id ?? '');
          }}
          getLabel={(value) => themeOptions.find((theme) => theme.key === value)?.themeName ?? value}
        />

        {proposalType === 'exercise' ? (
          <>
            <Text style={styles.fieldLabel}>{tr('selectLesson')}</Text>
            <SelectionPills
              options={selectedThemeOption?.lessons.map((lesson) => lesson.id) ?? []}
              selected={selectedLessonId}
              onSelect={setSelectedLessonId}
              getLabel={(value) =>
                selectedThemeOption?.lessons.find((lesson) => lesson.id === value)?.title ?? value
              }
            />
          </>
        ) : null}
      </View>

      {proposalType === 'lesson' ? (
        <>
          <View style={styles.formCard}>
            <Text style={styles.sectionTitle}>{tr('lessonProposal')}</Text>

            <Text style={styles.fieldLabel}>{tr('lessonId')}</Text>
            <TextInput value={lessonId} onChangeText={setLessonId} style={styles.input} />

            <Text style={styles.fieldLabel}>{tr('lessonTitle')}</Text>
            <TextInput value={lessonTitle} onChangeText={setLessonTitle} style={styles.input} />

            <Text style={styles.fieldLabel}>{tr('topic')}</Text>
            <TextInput value={lessonTopic} onChangeText={setLessonTopic} style={styles.input} />

            <Text style={styles.fieldLabel}>{tr('type')}</Text>
            <MultiSelectPills
              options={lessonFormats}
              selected={lessonProposalFormats}
              onToggle={toggleLessonFormat}
              getLabel={(value) => formatTypeLabel(value)}
            />
          </View>

          {lessonExerciseDrafts.map((draft, index) => (
            <ExerciseDraftEditor
              key={`lesson-exercise-${index}`}
              draft={draft}
              title={`${tr('exerciseProposal')} ${index + 1}`}
              onChange={(next) =>
                setLessonExerciseDrafts((prev) =>
                  prev.map((item, itemIndex) => (itemIndex === index ? next : item))
                )
              }
            />
          ))}

          <Pressable
            onPress={() => setLessonExerciseDrafts((prev) => [...prev, createExerciseDraft()])}
            style={styles.secondaryButton}
          >
            <Text style={styles.secondaryButtonText}>{tr('newExercise')}</Text>
          </Pressable>
        </>
      ) : (
        <ExerciseDraftEditor
          draft={singleExerciseDraft}
          title={tr('exerciseProposal')}
          onChange={setSingleExerciseDraft}
        />
      )}

      <Pressable onPress={submitProposal} style={styles.submitButton}>
        <Text style={styles.submitButtonText}>{tr('submitProposal')}</Text>
      </Pressable>

      {proposalPreview ? (
        <View style={styles.previewCard}>
          <Text style={styles.sectionTitle}>{tr('previewJson')}</Text>
          <Text style={styles.fieldHint}>{tr('proposalSaved')}</Text>
          <ScrollView horizontal>
            <Text style={styles.previewText}>{proposalPreview}</Text>
          </ScrollView>
        </View>
      ) : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingBottom: 40,
    paddingHorizontal: 20,
    paddingTop: 12
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  backButton: {
    alignSelf: 'flex-start',
    backgroundColor: 'rgba(226,232,240,0.95)',
    borderRadius: 10,
    paddingHorizontal: 18,
    paddingVertical: 12
  },
  backButtonText: {
    color: '#1E293B',
    fontSize: 18,
    fontWeight: '700'
  },
  pageTitle: {
    color: '#0F172A',
    fontSize: 30,
    fontWeight: '800',
    marginTop: 12,
    textAlign: 'center'
  },
  pageMeta: {
    color: '#475569',
    fontSize: 18,
    marginTop: 4,
    textAlign: 'center'
  },
  formCard: {
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderColor: '#CBD5E1',
    borderRadius: 14,
    borderWidth: 1,
    marginTop: 14,
    padding: 14
  },
  sectionTitle: {
    color: '#0F172A',
    fontSize: 22,
    fontWeight: '800'
  },
  fieldLabel: {
    color: '#334155',
    fontSize: 16,
    fontWeight: '700',
    marginTop: 12
  },
  fieldHint: {
    color: '#64748B',
    fontSize: 14,
    marginTop: 6
  },
  input: {
    backgroundColor: '#FFFFFF',
    borderColor: '#CBD5E1',
    borderRadius: 10,
    borderWidth: 1,
    color: '#0F172A',
    fontSize: 16,
    marginTop: 6,
    paddingHorizontal: 12,
    paddingVertical: 10
  },
  textArea: {
    minHeight: 90,
    textAlignVertical: 'top'
  },
  pillsWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 8
  },
  pill: {
    backgroundColor: '#E2E8F0',
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8
  },
  pillActive: {
    backgroundColor: '#1D4ED8'
  },
  pillText: {
    color: '#1E293B',
    fontSize: 15,
    fontWeight: '700'
  },
  pillTextActive: {
    color: '#FFFFFF'
  },
  secondaryButton: {
    alignSelf: 'flex-start',
    backgroundColor: '#E0F2FE',
    borderRadius: 10,
    marginTop: 12,
    paddingHorizontal: 14,
    paddingVertical: 10
  },
  secondaryButtonText: {
    color: '#0C4A6E',
    fontSize: 15,
    fontWeight: '700'
  },
  quizQuestionCard: {
    backgroundColor: '#F8FAFC',
    borderRadius: 10,
    marginTop: 12,
    padding: 10
  },
  submitButton: {
    alignItems: 'center',
    backgroundColor: '#16A34A',
    borderRadius: 12,
    marginTop: 16,
    paddingHorizontal: 18,
    paddingVertical: 14
  },
  submitButtonText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '800'
  },
  previewCard: {
    backgroundColor: 'rgba(15,23,42,0.92)',
    borderRadius: 14,
    marginTop: 16,
    padding: 14
  },
  previewText: {
    color: '#E2E8F0',
    fontFamily: Platform.select({ ios: 'Menlo', android: 'monospace', default: 'monospace' }),
    fontSize: 13,
    marginTop: 10
  }
});
