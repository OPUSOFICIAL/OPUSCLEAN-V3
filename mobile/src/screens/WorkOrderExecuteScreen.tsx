import { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  TextInput,
  StyleSheet,
  Alert,
  Modal,
  Image,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import {
  WorkOrder,
  ChecklistTemplate,
  ChecklistItem,
  ChecklistAnswer,
  CapturedPhoto,
  User,
} from '../types';
import { takePhoto, pickFromGallery, pickMultipleFromGallery, getBase64DataUrl } from '../utils/imageUtils';

interface WorkOrderExecuteScreenProps {
  workOrder: WorkOrder;
  checklist: ChecklistTemplate | null;
  user: User;
  isOnline: boolean;
  onComplete: (answers: Record<string, ChecklistAnswer>, photos: CapturedPhoto[]) => Promise<boolean>;
  onPause: (reason: string, photos: CapturedPhoto[]) => Promise<boolean>;
  onResume: () => Promise<boolean>;
  onBack: () => void;
}

export function WorkOrderExecuteScreen({
  workOrder,
  checklist,
  user,
  isOnline,
  onComplete,
  onPause,
  onResume,
  onBack,
}: WorkOrderExecuteScreenProps) {
  const [answers, setAnswers] = useState<Record<string, ChecklistAnswer>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isPauseModalOpen, setIsPauseModalOpen] = useState(false);
  const [pauseReason, setPauseReason] = useState('');
  const [pausePhotos, setPausePhotos] = useState<CapturedPhoto[]>([]);
  const [photoPreview, setPhotoPreview] = useState<CapturedPhoto | null>(null);

  useEffect(() => {
    if (checklist?.items) {
      const initialAnswers: Record<string, ChecklistAnswer> = {};
      checklist.items.forEach((item) => {
        initialAnswers[item.id] = {
          itemId: item.id,
          type: item.type,
          value: getDefaultValue(item),
          photos: [],
        };
      });
      setAnswers(initialAnswers);
    }
  }, [checklist]);

  const getDefaultValue = (item: ChecklistItem): any => {
    switch (item.type) {
      case 'boolean':
        return null;
      case 'text':
      case 'number':
        return '';
      case 'select':
        return '';
      case 'checkbox':
        return [];
      case 'photo':
        return [];
      default:
        return null;
    }
  };

  const updateAnswer = (itemId: string, value: any) => {
    setAnswers((prev) => ({
      ...prev,
      [itemId]: {
        ...prev[itemId],
        value,
      },
    }));
  };

  const addPhotoToItem = async (itemId: string, useCamera: boolean) => {
    try {
      const photo = useCamera ? await takePhoto() : await pickFromGallery();
      if (photo) {
        setAnswers((prev) => ({
          ...prev,
          [itemId]: {
            ...prev[itemId],
            photos: [...(prev[itemId]?.photos || []), photo],
          },
        }));
      }
    } catch (error: any) {
      Alert.alert('Erro', error.message || 'Erro ao capturar foto');
    }
  };

  const removePhotoFromItem = (itemId: string, photoId: string) => {
    setAnswers((prev) => ({
      ...prev,
      [itemId]: {
        ...prev[itemId],
        photos: (prev[itemId]?.photos || []).filter((p) => p.id !== photoId),
      },
    }));
  };

  const validateChecklist = (): boolean => {
    if (!checklist?.items) return true;

    for (const item of checklist.items) {
      if (!item.required) continue;

      const answer = answers[item.id];
      if (!answer) return false;

      switch (item.type) {
        case 'boolean':
          if (answer.value === null || answer.value === undefined) return false;
          break;
        case 'text':
        case 'number':
          if (!answer.value || answer.value.toString().trim() === '') return false;
          break;
        case 'select':
          if (!answer.value) return false;
          break;
        case 'checkbox':
          if (!Array.isArray(answer.value) || answer.value.length === 0) return false;
          break;
        case 'photo':
          const minPhotos = item.validation?.photoMinCount || 1;
          if (!answer.photos || answer.photos.length < minPhotos) return false;
          break;
      }
    }

    return true;
  };

  const handleComplete = async () => {
    if (!validateChecklist()) {
      Alert.alert('Checklist Incompleto', 'Preencha todos os itens obrigatorios antes de finalizar.');
      return;
    }

    Alert.alert(
      'Concluir OS',
      'Deseja concluir esta ordem de servico?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Concluir',
          onPress: async () => {
            setIsSubmitting(true);
            try {
              const allPhotos: CapturedPhoto[] = [];
              Object.values(answers).forEach((answer) => {
                if (answer.photos) {
                  allPhotos.push(...answer.photos);
                }
              });

              const success = await onComplete(answers, allPhotos);
              if (success) {
                Alert.alert('Sucesso', 'OS concluida com sucesso!', [
                  { text: 'OK', onPress: onBack },
                ]);
              }
            } catch (error: any) {
              Alert.alert('Erro', error.message || 'Erro ao concluir OS');
            } finally {
              setIsSubmitting(false);
            }
          },
        },
      ]
    );
  };

  const handlePause = async () => {
    if (!pauseReason.trim()) {
      Alert.alert('Erro', 'Informe o motivo da pausa.');
      return;
    }

    setIsSubmitting(true);
    try {
      const success = await onPause(pauseReason, pausePhotos);
      if (success) {
        setIsPauseModalOpen(false);
        setPauseReason('');
        setPausePhotos([]);
        Alert.alert('Sucesso', 'OS pausada com sucesso!', [
          { text: 'OK', onPress: onBack },
        ]);
      }
    } catch (error: any) {
      Alert.alert('Erro', error.message || 'Erro ao pausar OS');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleResume = async () => {
    Alert.alert(
      'Retomar OS',
      'Deseja retomar esta ordem de servico?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Retomar',
          onPress: async () => {
            setIsSubmitting(true);
            try {
              const success = await onResume();
              if (success) {
                Alert.alert('Sucesso', 'OS retomada com sucesso!');
              }
            } catch (error: any) {
              Alert.alert('Erro', error.message || 'Erro ao retomar OS');
            } finally {
              setIsSubmitting(false);
            }
          },
        },
      ]
    );
  };

  const addPausePhoto = async (useCamera: boolean) => {
    try {
      const photo = useCamera ? await takePhoto() : await pickFromGallery();
      if (photo) {
        setPausePhotos((prev) => [...prev, photo]);
      }
    } catch (error: any) {
      Alert.alert('Erro', error.message || 'Erro ao capturar foto');
    }
  };

  const renderChecklistItem = (item: ChecklistItem) => {
    const answer = answers[item.id];

    return (
      <View key={item.id} style={styles.checklistItem}>
        <View style={styles.itemHeader}>
          <Text style={styles.itemLabel}>
            {item.label}
            {item.required && <Text style={styles.required}> *</Text>}
          </Text>
        </View>

        {item.type === 'boolean' && (
          <View style={styles.booleanContainer}>
            <TouchableOpacity
              style={[
                styles.booleanButton,
                answer?.value === true && styles.booleanButtonActive,
              ]}
              onPress={() => updateAnswer(item.id, true)}
            >
              <Text
                style={[
                  styles.booleanButtonText,
                  answer?.value === true && styles.booleanButtonTextActive,
                ]}
              >
                Sim
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.booleanButton,
                answer?.value === false && styles.booleanButtonActiveNo,
              ]}
              onPress={() => updateAnswer(item.id, false)}
            >
              <Text
                style={[
                  styles.booleanButtonText,
                  answer?.value === false && styles.booleanButtonTextActive,
                ]}
              >
                Nao
              </Text>
            </TouchableOpacity>
          </View>
        )}

        {item.type === 'text' && (
          <TextInput
            style={styles.textInput}
            placeholder="Digite aqui..."
            value={answer?.value || ''}
            onChangeText={(text) => updateAnswer(item.id, text)}
            multiline
          />
        )}

        {item.type === 'number' && (
          <TextInput
            style={styles.textInput}
            placeholder="Digite um numero..."
            value={answer?.value?.toString() || ''}
            onChangeText={(text) => updateAnswer(item.id, text.replace(/[^0-9.,]/g, ''))}
            keyboardType="numeric"
          />
        )}

        {item.type === 'select' && item.options && (
          <View style={styles.selectContainer}>
            {item.options.map((option) => (
              <TouchableOpacity
                key={option}
                style={[
                  styles.selectOption,
                  answer?.value === option && styles.selectOptionActive,
                ]}
                onPress={() => updateAnswer(item.id, option)}
              >
                <Text
                  style={[
                    styles.selectOptionText,
                    answer?.value === option && styles.selectOptionTextActive,
                  ]}
                >
                  {option}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        )}

        {item.type === 'checkbox' && item.options && (
          <View style={styles.checkboxContainer}>
            {item.options.map((option) => {
              const isChecked = (answer?.value || []).includes(option);
              return (
                <TouchableOpacity
                  key={option}
                  style={styles.checkboxOption}
                  onPress={() => {
                    const current = answer?.value || [];
                    const updated = isChecked
                      ? current.filter((v: string) => v !== option)
                      : [...current, option];
                    updateAnswer(item.id, updated);
                  }}
                >
                  <View style={[styles.checkbox, isChecked && styles.checkboxChecked]}>
                    {isChecked && <Text style={styles.checkmark}>✓</Text>}
                  </View>
                  <Text style={styles.checkboxLabel}>{option}</Text>
                </TouchableOpacity>
              );
            })}
          </View>
        )}

        {item.type === 'photo' && (
          <View style={styles.photoContainer}>
            <View style={styles.photoButtons}>
              <TouchableOpacity
                style={styles.photoButton}
                onPress={() => addPhotoToItem(item.id, true)}
              >
                <Text style={styles.photoButtonText}>Tirar Foto</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.photoButton, styles.photoButtonSecondary]}
                onPress={() => addPhotoToItem(item.id, false)}
              >
                <Text style={[styles.photoButtonText, styles.photoButtonTextSecondary]}>
                  Galeria
                </Text>
              </TouchableOpacity>
            </View>

            {answer?.photos && answer.photos.length > 0 && (
              <View style={styles.photoGrid}>
                {answer.photos.map((photo) => (
                  <TouchableOpacity
                    key={photo.id}
                    style={styles.photoThumbnail}
                    onPress={() => setPhotoPreview(photo)}
                  >
                    <Image source={{ uri: photo.uri }} style={styles.thumbnailImage} />
                    <TouchableOpacity
                      style={styles.removePhotoButton}
                      onPress={() => removePhotoFromItem(item.id, photo.id)}
                    >
                      <Text style={styles.removePhotoText}>X</Text>
                    </TouchableOpacity>
                  </TouchableOpacity>
                ))}
              </View>
            )}

            {item.validation?.photoMinCount && (
              <Text style={styles.photoHint}>
                Minimo {item.validation.photoMinCount} foto(s)
                {item.validation.photoMaxCount &&
                  `, maximo ${item.validation.photoMaxCount}`}
              </Text>
            )}
          </View>
        )}
      </View>
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open':
        return '#3B82F6';
      case 'in_progress':
        return '#F59E0B';
      case 'paused':
        return '#EF4444';
      case 'completed':
        return '#10B981';
      default:
        return '#6B7280';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'open':
        return 'Aberta';
      case 'in_progress':
        return 'Em Andamento';
      case 'paused':
        return 'Pausada';
      case 'completed':
        return 'Concluida';
      default:
        return status;
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>Voltar</Text>
        </TouchableOpacity>
        <View style={styles.headerInfo}>
          <Text style={styles.headerTitle}>OS #{workOrder.workOrderNumber}</Text>
          {!isOnline && (
            <View style={styles.offlineBadge}>
              <Text style={styles.offlineBadgeText}>Offline</Text>
            </View>
          )}
        </View>
      </View>

      <ScrollView style={styles.content} contentContainerStyle={styles.contentContainer}>
        <View style={styles.orderCard}>
          <View style={styles.orderHeader}>
            <Text style={styles.orderTitle}>{workOrder.title}</Text>
            <View
              style={[
                styles.statusBadge,
                { backgroundColor: getStatusColor(workOrder.status) + '20' },
              ]}
            >
              <Text style={[styles.statusText, { color: getStatusColor(workOrder.status) }]}>
                {getStatusLabel(workOrder.status)}
              </Text>
            </View>
          </View>

          {workOrder.description && (
            <Text style={styles.orderDescription}>{workOrder.description}</Text>
          )}

          <View style={styles.orderDetails}>
            <Text style={styles.detailText}>
              Local: {workOrder.siteName} - {workOrder.zoneName}
            </Text>
            <Text style={styles.detailText}>
              Data: {format(new Date(workOrder.scheduledDate), "dd/MM/yyyy", { locale: ptBR })}
            </Text>
            <Text style={styles.detailText}>Executante: {user.name}</Text>
          </View>
        </View>

        {checklist && checklist.items.length > 0 && (
          <View style={styles.checklistSection}>
            <Text style={styles.sectionTitle}>Checklist: {checklist.name}</Text>
            {checklist.items
              .sort((a, b) => a.order - b.order)
              .map(renderChecklistItem)}
          </View>
        )}

        <View style={styles.actionButtons}>
          {workOrder.status === 'paused' ? (
            <TouchableOpacity
              style={[styles.actionButton, styles.resumeButton]}
              onPress={handleResume}
              disabled={isSubmitting}
            >
              {isSubmitting ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <Text style={styles.actionButtonText}>Retomar OS</Text>
              )}
            </TouchableOpacity>
          ) : (
            <>
              <TouchableOpacity
                style={[styles.actionButton, styles.completeButton]}
                onPress={handleComplete}
                disabled={isSubmitting}
              >
                {isSubmitting ? (
                  <ActivityIndicator color="#fff" />
                ) : (
                  <Text style={styles.actionButtonText}>Concluir OS</Text>
                )}
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.actionButton, styles.pauseButton]}
                onPress={() => setIsPauseModalOpen(true)}
                disabled={isSubmitting}
              >
                <Text style={[styles.actionButtonText, styles.pauseButtonText]}>
                  Pausar OS
                </Text>
              </TouchableOpacity>
            </>
          )}
        </View>
      </ScrollView>

      <Modal
        visible={isPauseModalOpen}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setIsPauseModalOpen(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Pausar Ordem de Servico</Text>

            <Text style={styles.inputLabel}>Motivo da pausa *</Text>
            <TextInput
              style={styles.pauseInput}
              placeholder="Informe o motivo..."
              value={pauseReason}
              onChangeText={setPauseReason}
              multiline
              numberOfLines={4}
            />

            <Text style={styles.inputLabel}>Fotos (opcional)</Text>
            <View style={styles.photoButtons}>
              <TouchableOpacity
                style={styles.photoButton}
                onPress={() => addPausePhoto(true)}
              >
                <Text style={styles.photoButtonText}>Tirar Foto</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.photoButton, styles.photoButtonSecondary]}
                onPress={() => addPausePhoto(false)}
              >
                <Text style={[styles.photoButtonText, styles.photoButtonTextSecondary]}>
                  Galeria
                </Text>
              </TouchableOpacity>
            </View>

            {pausePhotos.length > 0 && (
              <View style={styles.photoGrid}>
                {pausePhotos.map((photo) => (
                  <View key={photo.id} style={styles.photoThumbnail}>
                    <Image source={{ uri: photo.uri }} style={styles.thumbnailImage} />
                    <TouchableOpacity
                      style={styles.removePhotoButton}
                      onPress={() =>
                        setPausePhotos((prev) => prev.filter((p) => p.id !== photo.id))
                      }
                    >
                      <Text style={styles.removePhotoText}>X</Text>
                    </TouchableOpacity>
                  </View>
                ))}
              </View>
            )}

            <View style={styles.modalButtons}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setIsPauseModalOpen(false);
                  setPauseReason('');
                  setPausePhotos([]);
                }}
              >
                <Text style={styles.modalButtonCancelText}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={handlePause}
                disabled={isSubmitting}
              >
                {isSubmitting ? (
                  <ActivityIndicator color="#fff" size="small" />
                ) : (
                  <Text style={styles.modalButtonConfirmText}>Confirmar Pausa</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      <Modal
        visible={!!photoPreview}
        animationType="fade"
        transparent={true}
        onRequestClose={() => setPhotoPreview(null)}
      >
        <View style={styles.previewOverlay}>
          <TouchableOpacity
            style={styles.previewClose}
            onPress={() => setPhotoPreview(null)}
          >
            <Text style={styles.previewCloseText}>Fechar</Text>
          </TouchableOpacity>
          {photoPreview && (
            <Image
              source={{ uri: photoPreview.uri }}
              style={styles.previewImage}
              resizeMode="contain"
            />
          )}
        </View>
      </Modal>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  header: {
    backgroundColor: '#3B82F6',
    paddingTop: 50,
    paddingHorizontal: 16,
    paddingBottom: 16,
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    paddingVertical: 8,
    paddingRight: 16,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '500',
  },
  headerInfo: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  headerTitle: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  offlineBadge: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  offlineBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '500',
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 16,
    paddingBottom: 100,
  },
  orderCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  orderHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  orderTitle: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#1e293b',
    marginRight: 12,
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '500',
  },
  orderDescription: {
    fontSize: 14,
    color: '#64748b',
    marginBottom: 12,
  },
  orderDetails: {
    borderTopWidth: 1,
    borderTopColor: '#e2e8f0',
    paddingTop: 12,
  },
  detailText: {
    fontSize: 13,
    color: '#64748b',
    marginBottom: 4,
  },
  checklistSection: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1e293b',
    marginBottom: 16,
  },
  checklistItem: {
    marginBottom: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e2e8f0',
  },
  itemHeader: {
    marginBottom: 8,
  },
  itemLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#334155',
  },
  required: {
    color: '#EF4444',
  },
  booleanContainer: {
    flexDirection: 'row',
    gap: 12,
  },
  booleanButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#e2e8f0',
    alignItems: 'center',
  },
  booleanButtonActive: {
    backgroundColor: '#10B981',
    borderColor: '#10B981',
  },
  booleanButtonActiveNo: {
    backgroundColor: '#EF4444',
    borderColor: '#EF4444',
  },
  booleanButtonText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#64748b',
  },
  booleanButtonTextActive: {
    color: '#fff',
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    minHeight: 44,
    textAlignVertical: 'top',
  },
  selectContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  selectOption: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  selectOptionActive: {
    backgroundColor: '#3B82F6',
    borderColor: '#3B82F6',
  },
  selectOptionText: {
    fontSize: 14,
    color: '#64748b',
  },
  selectOptionTextActive: {
    color: '#fff',
    fontWeight: '500',
  },
  checkboxContainer: {
    gap: 8,
  },
  checkboxOption: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 4,
    borderWidth: 2,
    borderColor: '#e2e8f0',
    marginRight: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxChecked: {
    backgroundColor: '#3B82F6',
    borderColor: '#3B82F6',
  },
  checkmark: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  checkboxLabel: {
    fontSize: 14,
    color: '#334155',
  },
  photoContainer: {
    gap: 12,
  },
  photoButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  photoButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    backgroundColor: '#3B82F6',
    alignItems: 'center',
  },
  photoButtonSecondary: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#3B82F6',
  },
  photoButtonText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#fff',
  },
  photoButtonTextSecondary: {
    color: '#3B82F6',
  },
  photoGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 8,
  },
  photoThumbnail: {
    position: 'relative',
  },
  thumbnailImage: {
    width: 80,
    height: 80,
    borderRadius: 8,
  },
  removePhotoButton: {
    position: 'absolute',
    top: -8,
    right: -8,
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#EF4444',
    alignItems: 'center',
    justifyContent: 'center',
  },
  removePhotoText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  photoHint: {
    fontSize: 12,
    color: '#64748b',
    fontStyle: 'italic',
  },
  actionButtons: {
    gap: 12,
    marginTop: 16,
  },
  actionButton: {
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  completeButton: {
    backgroundColor: '#10B981',
  },
  pauseButton: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F59E0B',
  },
  resumeButton: {
    backgroundColor: '#3B82F6',
  },
  actionButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
  },
  pauseButtonText: {
    color: '#F59E0B',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 20,
    textAlign: 'center',
  },
  inputLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#334155',
    marginBottom: 8,
  },
  pauseInput: {
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    minHeight: 100,
    textAlignVertical: 'top',
    marginBottom: 16,
  },
  modalButtons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 20,
  },
  modalButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  modalButtonCancel: {
    backgroundColor: '#f1f5f9',
  },
  modalButtonConfirm: {
    backgroundColor: '#F59E0B',
  },
  modalButtonCancelText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#64748b',
  },
  modalButtonConfirmText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
  },
  previewOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.9)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  previewClose: {
    position: 'absolute',
    top: 50,
    right: 20,
    zIndex: 10,
    padding: 10,
  },
  previewCloseText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '500',
  },
  previewImage: {
    width: '100%',
    height: '80%',
  },
});
