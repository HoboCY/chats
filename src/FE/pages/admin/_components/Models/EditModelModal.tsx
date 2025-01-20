import React, { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import toast from 'react-hot-toast';

import useTranslation from '@/hooks/useTranslation';

import {
  AdminModelDto,
  GetModelKeysResult,
  UpdateModelDto,
} from '@/types/adminApis';

import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Form, FormField } from '@/components/ui/form';
import FormInput from '@/components/ui/form/input';
import FormSelect from '@/components/ui/form/select';
import FormSwitch from '@/components/ui/form/switch';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';

import { deleteModels, putModels } from '@/apis/adminApis';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

interface IProps {
  isOpen: boolean;
  selected: AdminModelDto;
  modelKeys: GetModelKeysResult[];
  onClose: () => void;
  onSuccessful: () => void;
  saveLoading?: boolean;
}

const EditModelModal = (props: IProps) => {
  const { t } = useTranslation();
  const { isOpen, onClose, selected, onSuccessful, modelKeys } = props;

  const formSchema = z.object({
    modelReferenceName: z.string(),
    name: z
      .string()
      .min(1, `${t('This field is require')}`)
      .optional(),
    modelId: z.string().optional(),
    enabled: z.boolean().optional(),
    deploymentName: z.string().optional(),
    modelKeyId: z.string().nullable().default(null),
    inputPrice1M: z.coerce.number(),
    outputPrice1M: z.coerce.number(),
  });

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      modelReferenceName: '',
      name: '',
      modelId: '',
      enabled: true,
      deploymentName: '',
      modelKeyId: '',
      inputPrice1M: 0,
      outputPrice1M: 0,
    },
  });

  function onSubmit(values: z.infer<typeof formSchema>) {
    if (!form.formState.isValid) return;
    const dto: UpdateModelDto = {
      deploymentName: values.deploymentName || null,
      enabled: values.enabled!,
      inputTokenPrice1M: values.inputPrice1M,
      outputTokenPrice1M: values.outputPrice1M,
      modelKeyId: parseInt(values.modelKeyId!),
      modelReferenceId: selected.modelReferenceId,
      name: values.name!,
    };
    putModels(values.modelId!, dto).then(() => {
      onSuccessful();
      toast.success(t('Save successful'));
    });
  }

  async function onDelete() {
    try {
      await deleteModels(selected!.modelId);
      onSuccessful();
      toast.success(t('Deleted successful'));
    } catch (err: any) {
      try {
        const resp = await err.json();
        toast.error(t(resp.message));
      } catch {
        toast.error(
          t(
            'Operation failed, Please try again later, or contact technical personnel',
          ),
        );
      }
    }
  }

  useEffect(() => {
    if (isOpen) {
      form.reset();
      form.formState.isValid;
      const {
        name,
        modelId,
        modelReferenceName,
        enabled,
        modelKeyId,
        deploymentName,
        inputTokenPrice1M,
        outputTokenPrice1M,
      } = selected;
      form.setValue('name', name);
      form.setValue('modelId', modelId.toString());
      form.setValue('enabled', enabled);
      form.setValue('modelKeyId', modelKeyId.toString());
      form.setValue('deploymentName', deploymentName || '');
      form.setValue('inputPrice1M', inputTokenPrice1M);
      form.setValue('outputPrice1M', outputTokenPrice1M);
      form.setValue('modelReferenceName', modelReferenceName);
    }
  }, [isOpen]);

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t('Edit Model')}</DialogTitle>
        </DialogHeader>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)}>
            <div className="grid grid-cols-2 gap-4">
              <FormField
                key="name"
                control={form.control}
                name="name"
                render={({ field }) => {
                  return (
                    <FormInput field={field} label={t('Model Display Name')!} />
                  );
                }}
              ></FormField>
              <div className="flex justify-between">
                <FormField
                  key="modelKeyId"
                  control={form.control}
                  name="modelKeyId"
                  render={({ field }) => {
                    return (
                      <FormSelect
                        className="w-full"
                        field={field}
                        label={t('Model Keys')!}
                        items={modelKeys
                          .filter(
                            (x) =>
                              x.modelProviderId === selected.modelProviderId,
                          )
                          .map((keys) => ({
                            name: keys.name,
                            value: keys.id.toString(),
                          }))}
                      />
                    );
                  }}
                ></FormField>
                <div
                  hidden={!form.getValues('modelKeyId')}
                  className="text-sm mt-12 w-36 text-right"
                >
                  <Popover>
                    <PopoverTrigger>
                      <span className="text-primary">
                        {t('Click View Configs')}
                      </span>
                    </PopoverTrigger>
                    <PopoverContent className="w-full">
                      {JSON.stringify(
                        modelKeys
                          .find(
                            (x) =>
                              x.id === parseInt(form.getValues('modelKeyId')!),
                          )
                          ?.toConfigs(),
                        null,
                        2,
                      )}
                    </PopoverContent>
                  </Popover>
                </div>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <FormField
                key="modelReferenceName"
                control={form.control}
                name="modelReferenceName"
                render={({ field }) => {
                  return (
                    <FormInput
                      field={field}
                      label={t('Model Version')!}
                    />
                  );
                }}
              ></FormField>
              <FormField
                key="deploymentName"
                control={form.control}
                name="deploymentName"
                render={({ field }) => {
                  return (
                    <FormInput label={t('Deployment Name')!} field={field} />
                  );
                }}
              ></FormField>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <FormField
                key="inputPrice1M"
                control={form.control}
                name="inputPrice1M"
                render={({ field }) => {
                  return (
                    <FormInput
                      type="number"
                      label={`${t('1M input tokens price')}(${t('Yuan')})`}
                      field={field}
                    />
                  );
                }}
              ></FormField>
              <FormField
                key="outputPrice1M"
                control={form.control}
                name="outputPrice1M"
                render={({ field }) => {
                  return (
                    <FormInput
                      type="number"
                      label={`1M ${t('1M output tokens price')}(${t('Yuan')})`}
                      field={field}
                    />
                  );
                }}
              ></FormField>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="flex gap-4">
                <FormField
                  key={'enabled'}
                  control={form.control}
                  name={'enabled'}
                  render={({ field }) => {
                    return (
                      <FormSwitch label={t('Is it enabled')!} field={field} />
                    );
                  }}
                ></FormField>
              </div>
            </div>
            <DialogFooter className="pt-4">
              <Button
                type="button"
                variant="destructive"
                onClick={(e) => {
                  onDelete();
                  e.preventDefault();
                }}
              >
                {t('Delete')}
              </Button>
              <Button type="submit">{t('Save')}</Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
};
export default EditModelModal;
