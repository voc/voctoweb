ActiveAdmin.register SiteSettings do
  menu :parent => "Misc"

  actions :all, except: [:new, :destroy]

  permit_params :promoted_banner_url, :live_banner_url, :logo_url, :logo_alt

  # Singleton: route everything to the one row.
  controller do
    before_action :load_singleton, only: [:index, :show, :edit, :update]

    def load_singleton
      params[:id] ||= SiteSettings.current.id.to_s
    end

    def index
      redirect_to edit_admin_site_setting_path(SiteSettings.current)
    end

    def show
      redirect_to edit_admin_site_setting_path(SiteSettings.current)
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Promoted banner' do
      f.input :promoted_banner_url,
              label: 'Promoted banner image URL',
              hint: 'Full URL to the background image used by .promoted.themed-banner. ' \
                    "Leave blank for the default:  \"#{SiteSettings::DEFAULT_BANNER_URL}\"."
      f.input :live_banner_url,
              label: 'Live banner image URL (optional)',
              hint: 'Full URL to a separate background image used on the .live banner. ' \
                    'Leave blank to reuse the promoted banner image.'
    end
    f.inputs 'Logo' do
      f.input :logo_url,
              label: 'Logo image URL',
              hint: 'Full URL to the logo shown in the navbar. ' \
                    "Default:  \"#{SiteSettings::DEFAULT_LOGO_URL}\"."
      f.input :logo_alt,
              label: 'Logo alt text',
              hint: 'For accessiblity, set when the logo is noticeably different from the default.' \
                    "Default: \"#{SiteSettings::DEFAULT_LOGO_ALT}\"."
    end
    f.actions do
      f.action :submit, label: 'Save'
    end
  end
end
